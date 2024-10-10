# Hackathon "Kong Go"

A template repository to develop Kong plugins based on Go.

## Pre-requisites
* Docker
* Docker Compose
* Go 1.23 or higher


## Useful local URLs

* Kong Manager UI: [`http://localhost:8002`](http://localhost:8002)
* Kong Admin API: [`http://localhost:8001`](http://localhost:8001)
* Kong Gateway: [`http://localhost:8000`](http://localhost:8000)


* Keycloak Admin UI: [`http://kc:8080/admin/master/console/`](http://kc:8080/admin/master/console/)
* Keycloak User UI: [`http://kc:8080/auth/realms/master/account/`](http://kc:8080/auth/realms/master/account/)

## Useful Documentation

* [Kong Gateway v3.7.x Documentation](https://docs.konghq.com/gateway/3.7.x/)
* [Kong Gateway v3.7.x Plugin Development Guide (Go)](https://docs.konghq.com/gateway/3.7.x/plugin-development/pluginserver/go/)
* [Kong Gateway v3.7.x Plugin Priority List](https://docs.konghq.com/konnect/reference/plugins/#plugin-execution-order)

## Structure and Conventions

* Plugins are developed in the `plugins` directory. Each plugin's entry point is a Go file with the suffix
  `*.plugin.go` (e.g. `demo.plugin.go`).
* Every plugin must contain a `main` function that calls the PDK's `server.StartServer` function.
    ```go
    package main
    import (
	    "github.com/Kong/go-pdk/server"
	    "plugins/demo"
    )
  
    func main() {
        _ = server.StartServer(demo.New, demo.Version, demo.Priority)
    }
    ```
* The `server.StartServer` function takes three arguments:
    * `New` - A function that returns a new instance of the plugin.
    * `Version` - The version of the plugin.
    * `Priority` - The priority of the plugin (
      check [plugin priority list](https://docs.konghq.com/konnect/reference/plugins/#plugin-execution-order)).
* As a best practice, the plugin's further logic should be implemented in a separate package (e.g. `demo`).
* Plugins following this approach are built and copied to the `/usr/local/bin/kong-plugins` directory of Kong
  automatically during the Kong image build process.

## How to develop a plugin

1. Create a new go file in the `plugins` directory with the suffix `*.plugin.go` (e.g. `myplugin.plugin.go`).
2. Have this file implement the `main` function that calls the PDK's `server.StartServer` function.
3. Follow this [guide](https://docs.konghq.com/gateway/3.7.x/plugin-development/pluginserver/go/) to implement the
   plugin.

## How to build a plugin

1. You don't. At least not on its own. The plugins are built and copied to the `/usr/local/bin/kong-plugins` directory
   of Kong automatically during the Kong image build process.

## How to test a plugin

1. To test the plugin using the local Kong instance, register the plugin in the [`kong.env`](./kong.env) file:
    ```env
    # Register all bundled and additional plugins
    KONG_PLUGINS=bundled,demo,...,myplugin
    KONG_PLUGINSERVER_NAMES=demo,...,myplugin
    
    # demo
    KONG_PLUGINSERVER_DEMO_SOCKET=/usr/local/kong/demo.socket
    KONG_PLUGINSERVER_DEMO_START_CMD=/usr/local/bin/kong-plugins/demo
    KONG_PLUGINSERVER_DEMO_QUERY_CMD=/usr/local/bin/kong-plugins/demo -dump
    
    # myplugin
    KONG_PLUGINSERVER_MYPLUGIN_SOCKET=/usr/local/kong/myplugin.socket
    KONG_PLUGINSERVER_MYPLUGIN_START_CMD=/usr/local/bin/kong-plugins/myplugin
    KONG_PLUGINSERVER_MYPLUGIN_QUERY_CMD=/usr/local/bin/kong-plugins/myplugin -dump
    ```
2. Add an entry for keycloak in the `/etc/hosts` file to resolve Keycloak locally:
    ```text
    # Hackathon Kong Go config
    127.0.0.1 kc
    ```
3. Run the `docker compose build --no-cache kong` command to build the Kong Gateway with the plugins.
4. Run the `docker compose up -d` command to start a Postgres DB, the initial migrations, and the Kong Gateway with the
   plugins. You might need to run it two times.
5. Test the plugin by creating a service and a route that uses the plugin (e.g. via Kong Manager UI).
6. Check the plugin logs using the `docker compose logs -f kong` command.