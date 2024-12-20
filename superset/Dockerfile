FROM apache/superset:latest

ARG ADMIN_USERNAME
ARG ADMIN_EMAIL
ARG ADMIN_PASSWORD

USER root
RUN pip install duckdb duckdb-engine

ENV ADMIN_USERNAME=${ADMIN_USERNAME} \
    ADMIN_EMAIL=${ADMIN_EMAIL} \
    ADMIN_PASSWORD=${ADMIN_PASSWORD}

COPY superset/superset-init.sh /superset-init.sh
RUN chmod +x /superset-init.sh  # Add this line to make the script executable

COPY superset/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

USER superset
ENTRYPOINT [ "/superset-init.sh" ]