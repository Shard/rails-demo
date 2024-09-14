# Valiant App

## Requirements
- Docker (with Compose CLI, Buildx optional)
- Terraform (To deploy to AWS)

## Quickstart

- `cp .env.example .env`
- `git clone git@github.com:Shard/rails-demo.git`
- `docker compose up -d --build`
- goto [localhost:3000](http://localhost:3000)

## CLI within Docker
One off commands via the CLI within the rails docker container can be directly invoked with:
`docker-compose run --rm web $CMD`

Or you can enter a bash session into currently running rails service with:
- `dp exec -it web bash`

# Services
- Postgres (Database)

# Deployment
Deployments are handled by Github Actions and Terraform.
