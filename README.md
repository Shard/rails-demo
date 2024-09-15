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

## Services
- Postgres (Database)
- Redis (Queues)

# Deployment
Deployments are handled by Github Actions and Terraform.

When a new commit is push to `master` and all required CI steps pass, a container artifact will be published to the github container registery.

Terraform manages all of the AWS infrastructure required to deploy the application and all of its services. When running `terraform apply` the latest `master` tagged image built via CI will be used for deployment.

## Dependencies
Valid AWS credentials must be present in `~/.aws/credentials` in order to use terraform to deploy to an account.

Terraform state is currently stored using HCP to allow GH actions access. Removing the reference in `main.tf` will allow for using terraform on a different AWS account.

# TODO
- [ ] Buy/Sell/Money

# Notes

## Zero Downtime maintaince
Using AWS Aurora [ZDP](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_UpgradeDBInstance.PostgreSQL.MinorUpgrade.html#USER_UpgradeDBInstance.PostgreSQL.Minor.zdp) feature allows for connections to be preserved when rolling out upgrades.

For a small database this will in most cases work fine, but as the database starts to grow bigger and more demand is put on it, the risks and length of an outage would naturally increase. Scaling out to more than 1 instance would be the first approach, to allow for rolling updates which for espicially read heavy loads can be a very effective measure.

Going further can also be adopting green/blue deployemnt stratergies to allow testing a production envrionement's deployment before sending it live. Green/Blue could also adopt more advanced systems of rollback triggering relating to metrics (eg: elevated 5XX errors, performance spikes, etc.) while also expanding out the time to fully change over.

Depending on the workload requirements and business requirements, other approaches could also be taken in terms of reducing data consistency requirements, either through postgres directly or by adopting other services (eg: elastic, mongo, clickhouse) in front of postgres that can not only offload and speedup workloads, but provide a buffer for postgres if it loses availability for any reason.

## Performance Monitoring
Utilizing Sentry Performance monitoring, we can profile a slice of all postgres queries via rails to give a basic view over what the most intensive and long running queries are, how their being executed, potentially even why it might be executed where you would not otherwise consider.

Going further can also be the approach of logging query plans in production/staging for particular types of queries we know to be problematic for analysis using different tools.

Another approach would be looking at the kinds of workloads that are being processed and investigating whether the postgres JIT should be enabled or disabled as it can have quite signifigant performance penalities if misconfigured.

Beyond that further approachs can involve adopting tools like grafana or datadog which are able to blend timeseries metrics with data such as logs, performance profile, predefined events based on prior investigation to help track down performance problems that might not be down to 1 system alone playing up.
