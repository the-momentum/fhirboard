# fhirboard

## App Purpose
The inspiration for this application came from attending the Analytics on FHIR conference. After watching several presentations, I realized there was a need for a practical environment to experience how [SQL on FHIR](https://build.fhir.org/ig/FHIR/sql-on-fhir-v2/) simplifies healthcare data analytics.
This project provides a containerized environment that, with a simple docker compose up command, gives you access to:

- A playground for experimenting with ViewDefinition and examining the generated results
- A DuckDB database for running analytical queries
- Superset integration for easy visualization of your results

### Main Features

- Define analytical use cases and create specific ViewDefinitions within them
- Preview SQL queries generated from individual ViewDefinitions (currently supporting [FlatQuack](https://github.com/gotdan/flatquack) runner for translating ViewDefinitions to DuckDB queries)
- View query results directly in the application
- Export defined queries as views to a DuckDB database, which is shared between the Rails App and Superset

### Who can use it?
- SQL-on-FHIR Enthusiasts: While there is a [playground](https://sql-on-fhir.org/extra/playground.html) on the official page, it doesn't allow you to run queries on your own FHIR export data or create views to combine data
- Data Analysts: Easily visualize FHIR analytics data - with the app and Superset in one container, you can get started quickly

##  Setup

### 1. Create `.env` file in project's root directory

```
RAILS_MASTER_KEY=*********
SUPERSET_ADMIN_USERNAME=*********
SUPERSET_ADMIN_PASSWORD=*********
SUPERSET_ADMIN_EMAIL=*********
SUPERSET_INTERNAL_URL="http://superset:8088"
SUPERSET_PUBLIC_URL="http://localhost:8088"
```

### 2. Build docker images and up compose

```
docker-compose up --build # running for first time to build images 

docker-compose up         # up compose
```

### 3. Seed database

To populate your database with initial sample data, run:
```
docker compose exec app bundle exec rails db:seed 
```

This command creates:
- one analytical case with two view definitions ([link](lib/examples/view_definitions/distribution_of_vaccinated_patients))
- a connection with the database in Superset
- macros in a DuckDB database which is shareable between the Rails app and Superset

### 4. Start using!  
After running above command, you will have:
- One analytical case with two example ViewDefinitions
- A persistent DuckDB database that can be accessed from both the app and Superset

All set! By default, the directory containing the exported FHIR data is set to `/app/fhir-export` - thanks to the configuration in docker-compose, it is shared between the FHIRboard application and Superset, making the dataset accessible in both locations. 
To use your own dataset, simply place your export files in the designated directory. Future releases will support direct upload of FHIR export data and potential integration with FHIR servers using bulk export API endpoints.

Below is a short video demonstrating the capabilities of this tool.

<video src="https://github.com/user-attachments/assets/a390f8da-5af5-4281-bb4a-f97b66aceacb" controls="controls"></video>

## Unit tests

Tests are written in RSpec and can be run with following command:

```
docker compose exec app bundle exec rspec
```
