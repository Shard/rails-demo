terraform {
  cloud {
    organization = "shard-org"
    workspaces {
      name = "rails-app"
    }
  }

  required_providers {
    docker = {
      source = "calxus/docker"
      version = "3.0.0"
    }
  }
}
provider "random" {}
provider "docker" {}

# AWS configuration
provider "aws" {
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                 = "default"
  region                  = "${var.aws_region}"
}
data "aws_caller_identity" "current" {}

#################
# Networking
#################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "rails-app-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  database_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway                 = true
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

#################
# RDS Database
#################
resource "random_password" "postgres_password" {
  length           = 16
  special          = false
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "rails-demo-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  database_name           = "rails_app_production"
  master_username         = "foo"
  master_password         = random_password.postgres_password.result

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  skip_final_snapshot     = true
  apply_immediately       = true
  db_subnet_group_name    = module.vpc.database_subnet_group_name
}

resource "aws_rds_cluster_instance" "database" {
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.postgresql.engine
  engine_version     = aws_rds_cluster.postgresql.engine_version
  db_subnet_group_name = module.vpc.database_subnet_group_name
}

#################
# Elasticache (Redis)
#################
resource "aws_elasticache_subnet_group" "redis-subnet" {
  name       = "cluster-redis-subnet-group"
  subnet_ids = module.vpc.database_subnets
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "cluster-redis"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis-subnet.name
}


#################
# Logging
#################
resource "aws_cloudwatch_log_group" "rails_log_group" {
  name = "rails-app-cloudwatch-log-group"
}

#################
# ECS Cluster
#################
resource "aws_security_group" "rails_app_sg" {
  name        = "rails-app-sg"
  description = "Allow traffic to the Rails app"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_ecs_cluster" "rails_cluster" {
  name = "rails-app-cluster"
}
resource "aws_ecs_cluster_capacity_providers" "ecs-cluster-capacity" {
  cluster_name       = aws_ecs_cluster.rails_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# IAM Role for ECS Task Execution
data "aws_iam_policy_document" "task_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
  inline_policy {
    name   = "task_execution_policy"
    policy = data.aws_iam_policy_document.task_execution_policy.json
  }
}

# Docker reference
# Used to pull a reference to the latest image for the task definition
data "docker_registry_image" "rails_app" {
  name = "ghcr.io/shard/rails-demo:master"
}
resource "docker_image" "rails_app" {
  name = data.docker_registry_image.rails_app.name
}

resource "aws_ecs_task_definition" "rails_task" {
  family                   = "rails-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([{
    name  = "rails-app"
    image = resource.docker_image.rails_app.repo_digest
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [{
      name  = "RAILS_ENV"
      value = "production"
    },{
      name  = "DATABASE_URL"
      value = "postgresql://foo:${random_password.postgres_password.result}@rails-demo-cluster.cluster-c92ciaceww0z.ap-southeast-2.rds.amazonaws.com:5432/rails_app_production"
    },{
      name  = "REDIS_URL"
      value = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:6379"
    },{
      name  = "SECRET_KEY_BASE"
      value = "not-used :)"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "${aws_cloudwatch_log_group.rails_log_group.id}"
        awslogs-region        = "${var.aws_region}"
        awslogs-create-group  = "true"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# Create ECS service
resource "aws_ecs_service" "rails_service" {
  name            = "rails-app-service"
  cluster         = aws_ecs_cluster.rails_cluster.id
  task_definition = aws_ecs_task_definition.rails_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.rails_app_sg.id]
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {}

output "vpc_id" {
  value = module.vpc.vpc_id
}
