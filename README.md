# Valiant App

## Requirements
- Docker (with Compose CLI, Buildx optional)
- Terraform (To deploy to AWS)

## Quickstart

- `cp .env.example .env`
- `git clone git@github.com:Shard/rails-demo.git`
- `docker compose up -d --build`
- goto [localhost:3000](http://localhost:3000)

## Usefull Commands
The docker container can be directly invoked with:
`docker-compose run --rm web $CMD`

Or you can enter bash into the container with:
- `dp exec -it web bash`

- `docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app ruby bundle lock --update`

# Services
- Postgres

# Deployment
gh actions


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
