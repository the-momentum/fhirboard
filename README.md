# fhirboard Backend

## App Purpose
The inspiration for this application came from attending the Analytics on FHIR conference. After watching several presentations, I realized there was a need for a practical environment to experience how [SQL on FHIR](https://build.fhir.org/ig/FHIR/sql-on-fhir-v2/) simplifies healthcare data analytics.
This project provides a containerized environment that, with a simple docker compose up command, gives you access to:

- A playground for experimenting with ViewDefinition and examining the generated results
- A DuckDB database for running analytical queries
- Superset integration for easy visualization of your results

### Main Features

- Define analytical use cases and create specific ViewDefinitions within them
- Preview SQL queries generated from individual ViewDefinitions (currently supporting FlatQuack runner for translating ViewDefinitions to DuckDB queries)
- View query results directly in the application
- Export defined queries as views to a DuckDB database, which is shared between the Rails App and Superset

##  Setup

### 1. Create `.env` file in project's root directory

```
RAILS_MASTER_KEY=*********
SUPERSET_ADMIN_USERNAME=*********
SUPERSET_ADMIN_PASSWORD=*********
SUPERSET_ADMIN_EMAIL=*********
```

### 2. Build docker images and up compose

```
docker-compose up --build # running for first time to build images 

docker-compose up         # up compose
```

## Unit tests

Tests are written in RSpec and can be run with following command:

```
docker compose exec app rspec
```