package main

import (
	"log"
	"net/http"
	"os"

	"example.com/api/handlers"
	"example.com/api/version"
)

func main() {
	log.Printf("Starting the service...\ncommit: %s, build time: %s, release: %s", version.Commit, version.BuildTime, version.Release)

	port := os.Getenv("PORT")
	if port == "" {
		log.Fatal("Port is not set.")
	}

	router := handlers.Router(version.BuildTime, version.Commit, version.Release)

	log.Print("The service is ready to listen at port " + port + " and serve.")
	log.Fatal(http.ListenAndServe(":"+port, router))
}
