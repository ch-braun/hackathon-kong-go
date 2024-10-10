package demo

import (
	"fmt"
	"github.com/Kong/go-pdk"
)

const (
	Version  = "0.1.0"
	Priority = 100
)

type PluginConfig struct {
	// Add your plugin configuration here
	Message            string `json:"message"`
	ResponseHeaderName string `json:"response_header_name"`
}

// New creates a new instance of your plugin
func New() interface{} {
	return &PluginConfig{}
}

/*
	Add phase handlers here
	Phases:
	- Certificate
	- Rewrite
	- Access
	- Response
	- Preread
	- Log
*/

// Access is called for every request from a client to the proxy
func (conf PluginConfig) Access(kong *pdk.PDK) {
	// Add your plugin logic here

	// Get the host header of the incoming request
	host, err := kong.Request.GetHeader("host")
	if err != nil {
		_ = kong.Log.Err("Could not get host header: " + err.Error())
		return
	}
	_ = kong.Log.Debug("Host header: " + host)

	// Get the message and response header name from the plugin configuration
	message := conf.Message
	if message == "" {
		message = "Hello, Hackathon! Greetings from Kong Go Demo Plugin!"
	}

	headerName := conf.ResponseHeaderName
	if headerName == "" {
		headerName = "X-Kong-Go-Demo"
	}

	// Modify the response header
	err = kong.Response.SetHeader(headerName, fmt.Sprintf("Kong says '%s' to %s", message, host))

	if err != nil {
		_ = kong.Log.Err("Could not set response header: " + err.Error())
	}
}
