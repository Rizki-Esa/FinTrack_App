package handlers

import (
	"fintrack-backend/config"
	"fintrack-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetTransactions(c *gin.Context) {

	userId := c.Param("userId")

	var transactions []models.Transaction

	config.DB.Where("user_id = ?", userId).Find(&transactions)

	c.JSON(http.StatusOK, transactions)
}

func CreateTransaction(c *gin.Context) {

	var transaction models.Transaction

	if err := c.ShouldBindJSON(&transaction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Create(&transaction)

	c.JSON(http.StatusOK, transaction)
}

func DeleteTransaction(c *gin.Context) {

	id := c.Param("id")

	config.DB.Delete(&models.Transaction{}, id)

	c.JSON(http.StatusOK, gin.H{
		"message": "Transaction deleted",
	})
}