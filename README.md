# Valiant App

## Requirements
- Docker (with Compose CLI, Buildx optional)

## Quickstart

- `cp .env.example .env`
- `git clone git@github.com:Shard/rails-demo.git`
- `docker compose up -d --build`
- goto [localhost:3000](http://localhost:3000)

Ruby console can be accessed from `docker-compose run --rm web $CMD`
- `docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app ruby bundle lock --update`

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
