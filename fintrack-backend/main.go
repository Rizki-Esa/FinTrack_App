package main

import (
	"fintrack-backend/config"
	"fintrack-backend/routes"
	"github.com/joho/godotenv"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"time"
)

func main() {
	godotenv.Load()
	// router
	r := gin.Default()

	// connect database
	config.ConnectDB()

	// ===== MIDDLEWARE =====
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// ===== CORS =====
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// serve static files dari folder ./uploads
	r.Static("/uploads", "./uploads")

	// setup routes
	routes.SetupRoutes(r)

	// run server
	r.Run(":8080")
}