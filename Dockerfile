# Description: Dockerfile for building Kong with custom Go plugins

ARG GO_VERSION="1.23"
ARG KONG_VERSION="3.7"

# Build custom plugins
FROM golang:${GO_VERSION} AS builder

COPY ./plugins /plugins

WORKDIR /plugins

RUN mkdir -p /plugins/out

# Build every plugin with the name of the file as the name of the plugin
RUN for plugin in ./*.plugin.go; do \
    go build -o /plugins/out/${plugin%.plugin.go} $plugin; \
    # Check if plugin was built successfully
    if [ ! -f /plugins/out/${plugin%.plugin.go} ]; then exit 1; fi; \
    done

# Package the plugins into the final image
FROM kong:${KONG_VERSION}

USER root

# Assemble Kong with custom plugins
COPY --from=builder /plugins/out /usr/local/bin/kong-plugins

RUN chmod +x /usr/local/bin/kong-plugins/*

# Reset back to the default user
USER kong