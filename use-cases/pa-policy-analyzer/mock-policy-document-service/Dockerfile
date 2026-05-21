# syntax=docker/dockerfile:1

# ---------- Build stage ----------
FROM ballerina/ballerina:2201.13.1 AS build

USER root
WORKDIR /build

COPY Ballerina.toml Dependencies.toml ./
COPY main.bal ./

RUN bal build

# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre-jammy

ARG USER_ID=10014
ARG GROUP_ID=10014

RUN groupadd -g ${GROUP_ID} choreouser \
    && useradd --no-log-init -u ${USER_ID} -g ${GROUP_ID} -m choreouser

WORKDIR /home/choreouser

COPY --from=build --chown=choreouser:choreouser /build/target/bin/mock_pdf_service.jar ./app.jar
COPY --chown=choreouser:choreouser policies ./policies

USER ${USER_ID}

EXPOSE 6092

CMD ["java", "-jar", "app.jar"]
