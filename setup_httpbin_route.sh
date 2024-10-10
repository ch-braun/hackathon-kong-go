#!/bin/bash

SERVICE_NAME=httpbin
UPSTREAM_URL=https://eu.httpbin.org

ROUTE_NAME=httpbin-route
BASEPATH=/httpbin/v1

KONG_ADMIN_URL=http://localhost:8001

# Delete the Route and Service if they already exist
curl -i -X DELETE --url ${KONG_ADMIN_URL}/services/${SERVICE_NAME}/routes/${ROUTE_NAME}
curl -i -X DELETE --url ${KONG_ADMIN_URL}/services/${SERVICE_NAME}

# Create a Gateway Service for the upstream service
curl -i -X POST --url ${KONG_ADMIN_URL}/services/ --data "name=${SERVICE_NAME}" --data "url=${UPSTREAM_URL}"

# Create a Route for the Gateway Service
curl -i -X POST --url ${KONG_ADMIN_URL}/services/httpbin/routes --data "paths[]=${BASEPATH}" --data "name=${ROUTE_NAME}"

# Test the Gateway Service
curl -i -X GET --url http://localhost:8000${BASEPATH}/get