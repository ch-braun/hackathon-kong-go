package main

import (
	"github.com/Kong/go-pdk/server"
	"plugins/demo"
)

func main() {
	_ = server.StartServer(demo.New, demo.Version, demo.Priority)
}
