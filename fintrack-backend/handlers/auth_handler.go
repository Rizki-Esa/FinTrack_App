package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fintrack-backend/config"
	"fintrack-backend/models"
	"fintrack-backend/utils"
	"fmt"
	"math/big"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type RegisterInput struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

func Register(c *gin.Context) {

	var input RegisterInput

	// 1️⃣ Validasi input
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid input",
		})
		return
	}

	// 2️⃣ Cek email sudah dipakai
	var existing models.User
	config.DB.Where("email = ?", input.Email).First(&existing)

	if existing.ID != 0 {
		c.JSON(http.StatusConflict, gin.H{
			"error": "Email already registered",
		})
		return
	}

	// 3️⃣ Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword(
		[]byte(input.Password),
		bcrypt.DefaultCost,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Password hashing failed",
		})
		return
	}

	// 4️⃣ Buat user baru
	user := models.User{
		Name:     input.Name,
		Email:    input.Email,
		Password: string(hashedPassword),
	}

	config.DB.Create(&user)

	// 5️⃣ Generate JWT (auto login)
	token, err := utils.GenerateJWT(user.ID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token generation failed",
		})
		return
	}

	// 6️⃣ Convert ke DTO
	userResponse := utils.ToUserResponse(user)

	// 7️⃣ Response
	c.JSON(http.StatusOK, gin.H{
		"message": "User registered successfully",
		"user":    userResponse,
		"token":   token,
	})
}
type LoginInput struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func Login(c *gin.Context) {

	var input LoginInput

	// 1️⃣ Validasi input
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid input",
		})
		return
	}

	// 2️⃣ Cari user
	var user models.User
	config.DB.Where("email = ?", input.Email).First(&user)

	if user.ID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid email or password",
		})
		return
	}

	// 3️⃣ Verifikasi password
	err := bcrypt.CompareHashAndPassword(
		[]byte(user.Password),
		[]byte(input.Password),
	)

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid email or password",
		})
		return
	}

	// 4️⃣ Generate JWT
	token, err := utils.GenerateJWT(user.ID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token generation failed",
		})
		return
	}

	// 5️⃣ Convert ke DTO
	userResponse := utils.ToUserResponse(user)

	// 6️⃣ Response
	c.JSON(http.StatusOK, gin.H{
		"message": "Login success",
		"user":    userResponse,
		"token":   token,
	})
}

type GoogleLoginInput struct {
	AccessToken string `json:"access_token"`
}

func GoogleLogin(c *gin.Context) {

	var input GoogleLoginInput

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	// 🔥 IMPORTANT: clean token
	input.AccessToken = strings.TrimSpace(input.AccessToken)

	req, err := http.NewRequest(
		"GET",
		"https://www.googleapis.com/oauth2/v2/userinfo",
		nil,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": "Request error"})
		return
	}

	req.Header.Set("Authorization", "Bearer "+input.AccessToken)

	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil {
		c.JSON(401, gin.H{"error": "Google request failed"})
		return
	}
	defer resp.Body.Close()

	// 🔥 DEBUG STEP (IMPORTANT)
	if resp.StatusCode != 200 {
		var errBody map[string]interface{}
		json.NewDecoder(resp.Body).Decode(&errBody)

		c.JSON(401, gin.H{
			"error": "Invalid Google access token",
			"debug": errBody,
		})
		return
	}

	var googleUser struct {
		Email string `json:"email"`
		Name  string `json:"name"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&googleUser); err != nil {
		c.JSON(500, gin.H{"error": "Failed to decode Google user"})
		return
	}

	// 🔍 find user
	var user models.User
	config.DB.Where("email = ?", googleUser.Email).First(&user)

	if user.ID == 0 {
		user = models.User{
			Name:  googleUser.Name,
			Email: googleUser.Email,
		}
		config.DB.Create(&user)
	}

	token, _ := utils.GenerateJWT(user.ID)

	c.JSON(200, gin.H{
		"user":  utils.ToUserResponse(user),
		"token": token,
	})
}

type ForgotPasswordInput struct {
	Email string `json:"email"`
}

func ForgotPassword(c *gin.Context) {

	var input struct {
		Email string `json:"email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	var user models.User
	config.DB.Where("email = ?", input.Email).First(&user)

	if user.ID == 0 {c.JSON(400, gin.H{"error": "Email tidak terdaftar",})
	return
}

	n, _ := rand.Int(rand.Reader, big.NewInt(1000000))
	otp := fmt.Sprintf("%06d", n.Int64())
	expiry := time.Now().Add(10 * time.Minute)

	user.ResetOTP = otp
	user.ResetOTPExpiry = &expiry
	config.DB.Save(&user)

	utils.SendOTPEmail(user.Email, otp)

	c.JSON(200, gin.H{"message": "OTP sent"})
}

type VerifyOTPInput struct {
	Email string `json:"email"`
	OTP   string `json:"otp"`
}

func VerifyOTP(c *gin.Context) {

	var input struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	var user models.User
	config.DB.Where("email = ?", input.Email).First(&user)

	if user.ID == 0 || user.ResetOTPExpiry == nil {
		c.JSON(400, gin.H{"error": "OTP tidak valid"})
		return
	}

	if time.Now().After(*user.ResetOTPExpiry) {
		c.JSON(400, gin.H{"error": "OTP expired"})
		return
	}

	if user.ResetOTP != input.OTP {
		c.JSON(400, gin.H{"error": "OTP salah"})
		return
	}

	// 🔥 Generate token
	tokenBytes := make([]byte, 32)
	rand.Read(tokenBytes)
	token := hex.EncodeToString(tokenBytes)

	expiry := time.Now().Add(10 * time.Minute)

	user.ResetToken = token
	user.ResetTokenExpiry = &expiry

	// hapus OTP
	user.ResetOTP = ""
	user.ResetOTPExpiry = nil

	config.DB.Save(&user)

	c.JSON(200, gin.H{
		"reset_token": token,
	})
}

type ResetPasswordInput struct {
	Token       string `json:"token"`
	NewPassword string `json:"new_password"`
}

func ResetPassword(c *gin.Context) {

	var input struct {
		Token       string `json:"token"`
		NewPassword string `json:"new_password"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": "Invalid input"})
		return
	}

	var user models.User
	config.DB.Where("reset_token = ?", input.Token).First(&user)

	if user.ID == 0 || user.ResetTokenExpiry == nil {
		c.JSON(400, gin.H{"error": "Token tidak valid"})
		return
	}

	if time.Now().After(*user.ResetTokenExpiry) {
		c.JSON(400, gin.H{"error": "Token expired"})
		return
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword(
		[]byte(input.NewPassword),
		bcrypt.DefaultCost,
	)

	user.Password = string(hashedPassword)

	// HAPUS TOKEN setelah dipakai
	user.ResetToken = ""
	user.ResetTokenExpiry = nil

	config.DB.Save(&user)

	c.JSON(200, gin.H{
		"message": "Password berhasil diubah",
	})
}