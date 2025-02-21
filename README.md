<div align="center">
  <img src="https://cdn.prod.website-files.com/66a1237564b8afdc9767dd3d/66df7b326efdddf8c1af9dbb_Momentum%20Logo.svg" height="64">

  [![Contact us](https://img.shields.io/badge/Contact%20us-AFF476.svg)](mailto:hello@themomentum.ai?subject=Terraform%20Modules)
  [![Check Momentum](https://img.shields.io/badge/Check%20Momentum-1f6ff9.svg)](https://themomentum.ai)
  [![MIT License](https://img.shields.io/badge/License-MIT-636f5a.svg?longCache=true)](LICENSE)
</div>

## Overview
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

##  Local setup

### 1. Create `.env` file in project's root directory

```
SUPERSET_INTERNAL_URL="http://superset:8088"
SUPERSET_PUBLIC_URL="http://localhost:8088"
```

### 2. Build docker images and up compose

```
# running for the first time to build images 
docker-compose -f docker-compose.dev.yml up --build                   

# up compose
docker compose -f docker-compose.dev.yml up 
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

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

Please review our contribution guidelines before submitting changes.

## Support

- Open an issue for bug reports or feature requests
- Contact us at hello@themomentum.ai for direct support

## Contributors

<a href="https://github.com/the-momentum/fhirboard/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=the-momentum/fhirboard" />
</a>

## License

FHIRboard is available under the MIT License.

---

*Built with ❤️ by [Momentum](https://themomentum.ai)*
