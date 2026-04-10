package routes

import (
	"fintrack-backend/handlers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {

	api := r.Group("/api")

	{
		api.GET("/test", handlers.TestAPI)

		api.POST("/register", handlers.Register)
		api.POST("/login", handlers.Login)

		api.POST("/forgot-password", handlers.ForgotPassword)
		api.POST("/verify-otp", handlers.VerifyOTP)
		api.POST("/reset-password", handlers.ResetPassword)
		api.POST("/google-login", handlers.GoogleLogin)

		api.GET("/profile/:id", handlers.GetProfile)
		api.PUT("/profile/:id", handlers.UpdateProfile)
		api.POST("/profile/:id/check-password", handlers.CheckPassword)
		api.POST("/profile/:id/image", handlers.UploadProfileImage)

		api.GET("/transactions/:userId", handlers.GetTransactions)
		api.POST("/transactions", handlers.CreateTransaction)
		api.DELETE("/transactions/:id", handlers.DeleteTransaction)
	}
}