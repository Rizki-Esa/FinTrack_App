package models

import "time"

type User struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name"`
	Email     string    `json:"email" gorm:"unique"`
	Password  string    `json:"password"`
	Bio       string    `json:"bio"`       
	Phone     string    `json:"phone"`    
	Image     string    `json:"image"`
	IsDarkMode bool     `json:"is_dark_mode" gorm:"default:false"`
	IsEnglish  bool     `json:"is_english" gorm:"default:false"`
	ResetToken       string     `json:"-" gorm:"index"`
	ResetTokenExpiry *time.Time `json:"-"`
	ResetOTP       string     `json:"-"`
	ResetOTPExpiry *time.Time `json:"-"`
	CreatedAt time.Time `json:"created_at"`

	Transactions []Transaction `gorm:"foreignKey:UserID"`
}