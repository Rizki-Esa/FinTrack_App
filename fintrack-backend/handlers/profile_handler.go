package handlers

import (
	"fintrack-backend/config"
	"fintrack-backend/models"
	"net/http"
	"golang.org/x/crypto/bcrypt"
	"github.com/gin-gonic/gin"
)

func GetProfile(c *gin.Context) {

	id := c.Param("id")

	var user models.User

	config.DB.First(&user, id)

	c.JSON(http.StatusOK, user)
}

func UpdateProfile(c *gin.Context) {

	id := c.Param("id")

	var user models.User

	// ambil user dari DB
	config.DB.First(&user, id)

	if user.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// struct untuk bind JSON update profile
	var input struct {
		Name        *string `json:"name"`
		Bio         *string `json:"bio"`
		Email       *string `json:"email"`
		Phone       *string `json:"phone"`
		Password    *string `json:"password"`
		NewPassword *string `json:"new_password"` 
		IsDarkMode  *bool   `json:"is_dark_mode"`
		IsEnglish   *bool   `json:"is_english"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// update field yang tidak kosong
	if input.Name != nil {
		user.Name = *input.Name
	}

	if input.Bio != nil {
		user.Bio = *input.Bio
	}

	if input.Email != nil {

		// 🔥 NORMALISASI (optional tapi bagus)
		email := *input.Email

		// 🔥 CEK EMAIL SUDAH DIPAKAI USER LAIN
		var existing models.User
		config.DB.Where("email = ? AND id <> ?", email, user.ID).First(&existing)

		if existing.ID != 0 {
			c.JSON(http.StatusConflict, gin.H{
				"error": "Email already registered",
			})
			return
		}

		user.Email = email
	}

	if input.Phone != nil {
		user.Phone = *input.Phone
	}

	if input.Password != nil && input.NewPassword != nil {
		// verifikasi password lama
		err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(*input.Password))
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Old password is incorrect"})
			return
		}

		// update password baru
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(*input.NewPassword), 14)
		user.Password = string(hashedPassword)
	}

	if input.IsDarkMode != nil {
	user.IsDarkMode = *input.IsDarkMode
	}

	if input.IsEnglish != nil {
		user.IsEnglish = *input.IsEnglish
	}

	// simpan perubahan
	config.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile updated successfully",
		"user":    user,
	})
}

func CheckPassword(c *gin.Context) {
	id := c.Param("id")

	var user models.User
	config.DB.First(&user, id)
	if user.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// Bind JSON untuk old_password
	var input struct {
		OldPassword string `json:"old_password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Cek password lama
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.OldPassword))
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"valid": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"valid": true})
}

func UploadProfileImage(c *gin.Context) {

	id := c.Param("id")

	var user models.User
	config.DB.First(&user, id)
	if user.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// ambil file dari form-data
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Image is required"})
		return
	}

	// simpan file ke folder local
	// misal folder ./uploads/
	filename := "uploads/user_" + id + "_" + file.Filename
	if err := c.SaveUploadedFile(file, filename); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image"})
		return
	}

	// update path image di DB
	user.Image = "/" + filename
	config.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{
		"message": "Image uploaded successfully",
		"user":    user,
	})
}