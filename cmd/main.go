package main

import (
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

func root(c echo.Context) error {
	return c.String(http.StatusOK, "Hello!")
}

func main() {
	e := echo.New()

	e.GET("/", root)

	s := http.Server{
		Addr:    ":8080",
		Handler: e,
	}

	if err := s.ListenAndServe(); err != http.ErrServerClosed {
		log.Fatal(err)
	}
}
