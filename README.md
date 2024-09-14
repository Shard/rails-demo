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
`docker compose exec -it web bash`

Update gem lockfile:
`docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app ruby bundle lock --update`

# Services
- Postgres (Database)

# Deployment
Deployments are handled by Github Actions and Terraform.

When a new commit is push to `master` and all required CI steps pass, a container artifact will be published to the github container registery 
