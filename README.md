# Ralis Stock Demo
Ruby on Rails application demonstrating the use of Docker, Terraform, Github actions and AWS to impliment a lightweight and secure CI/CD pipeline. Also contains stocks and the sun 🌞.

# Local Development

## Requirements
- Docker with Compose CLI (buildx optional but recomended)
- Terraform (For deployments to aws)

## Quickstart

- `git clone git@github.com:Shard/rails-demo.git`
- `cp .env.example .env`
- `docker compose up -d --build`
- Open [localhost:3000](http://localhost:3000)

## CLI within Docker
The project is setup to allow for all development to occur inside the container.

One off commands via the CLI within the rails docker container can be directly invoked with:
```bash
docker-compose run --rm web $CMD
```

Or you can enter a bash session into currently running rails service with:
```bash
docker compose exec -it web bash
```

Update gem lockfile:
```bash
docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app ruby bundle lock --update
```

## Internal Services
- Postgres - Single source of truth
- Redis - Provides backing for Resque Queues and ActionCable

# AWS Deployment
Deployments are handled by Github Actions and Terraform. The target is AWS Cloud.

When a new commit is pushed to `master` and all required CI steps pass, a container artifact will be published to the github container registry and a terraform plan will be generated. 

During this time the plan step can be inspected to see all the changes that will be made and the container will be available under [packages](https://github.com/Shard/rails-demo/pkgs/container/rails-demo). Once the [deployment](https://github.com/Shard/rails-demo/deployments) has been approved the plan will be applied to AWS.

Terraform manages all of the AWS infrastructure required to deploy the application and all of its supporting internal services. When running `terraform apply` the latest `master` tagged image built via CI will be used for deployment.

## Deployment Dependencies
Valid AWS credentials must be available to the [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration) provider along with `terraform` being installed.

## AWS Services
- Application Load Balancer
- Elastic Container Service/Fargate (Docker Compose in the cloud)
- RDS Aurora Serverless (Postgres)
- ElastiCache (Redis)
- Cloudwatch (Container and infrastructure metrics, Alerting)

# External Services

## Sentry
Sentry is used to collect and present Errors and Traces from both the frontend and backend.

## Hashicorp Cloud (HCP)
Terraform state is currently stored using HCP to allow Github actions access to the state. Removing the `terraform.cloud` block in `main.tf` to will allow for using terraform on a different AWS account.

# Notes on future improvements

## Zero Downtime maintaince
Using AWS Aurora [ZDP](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_UpgradeDBInstance.PostgreSQL.MinorUpgrade.html#USER_UpgradeDBInstance.PostgreSQL.Minor.zdp) feature allows for connections to be preserved when rolling out upgrades.

For a small database this will in most cases work fine, but as the database starts to grow bigger and more demand is put on it, the risks and length of an outage would naturally increase. Scaling out to more than 1 instance would be the first approach, to allow for rolling updates which for espicially read heavy loads can be a very effective measure.

Going further can also be adopting Green/Blue deployemnt stratergies to allow testing a production envrionement's deployment before sending it live. Green/Blue could also adopt more advanced systems of rollback triggering relating to metrics (eg: elevated 5XX errors, performance spikes, etc.) while also expanding out the time to fully change over.

Depending on the workload requirements and business requirements, other approaches could also be taken in terms of reducing data consistency requirements, either through postgres directly or by adopting other services (eg: elastic, mongo, clickhouse) in front of postgres that can not only offload and speedup workloads, but provide a buffer for postgres if it loses availability for any reason.

## Performance Monitoring
Utilizing Sentry Performance monitoring, we can profile a slice of all postgres queries via rails to give a basic view over what the most intensive and long running queries are, how their being executed, potentially even why it might be executed where you would not otherwise consider.

Going further can also be the approach of logging query plans in production/staging for particular types of queries we know to be problematic for analysis using different tools.

Another approach would be looking at the kinds of workloads that are being processed and investigating whether the postgres JIT should be enabled or disabled as it can have quite signifigant performance penalities if misconfigured.

Beyond that further approachs can involve adopting prometheus tools like grafana or datadog which are able to blend timeseries metrics with other ts-like data such as logs, performance profile, predefined events based on prior investigation to help track down performance problems that might not be down to 1 system alone playing up.
