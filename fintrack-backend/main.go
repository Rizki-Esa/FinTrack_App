package main

import (
	"log"
	"os"
	"time"

	"fintrack-backend/config"
	"fintrack-backend/routes"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {

	// ===== LOAD ENV =====
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found (using system environment)")
	}

	// ===== SET GIN MODE =====
	appEnv := os.Getenv("APP_ENV")
	if appEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// ===== INIT ROUTER =====
	r := gin.Default()

	// ===== CONNECT DATABASE =====
	config.ConnectDB()

	// ===== MIDDLEWARE =====
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// 🔐 FIX SECURITY WARNING
	r.SetTrustedProxies(nil)

	r.Use(cors.New(cors.Config{
		//AllowOrigins:     []string{FRONTEND_URL},
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// ===== STATIC FILES =====
	r.Static("/uploads", "./uploads")

	// ===== ROUTES =====
	routes.SetupRoutes(r)

	// ===== RUN SERVER =====
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // default
	}

	log.Println("Server running on port:", port)
	r.Run(":" + port)
}