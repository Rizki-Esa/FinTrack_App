package handlers

import "github.com/gin-gonic/gin"

func TestAPI(c *gin.Context) {

	c.JSON(200, gin.H{
		"message": "FinTrack Backend Running",
	})
}