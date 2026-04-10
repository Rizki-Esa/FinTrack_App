package models

type UserResponse struct {
	ID         uint   `json:"id"`
	Name       string `json:"name"`
	Email      string `json:"email"`
	Bio        string `json:"bio"`
	Phone      string `json:"phone"`
	Image      string `json:"image"`
	IsDarkMode bool   `json:"is_dark_mode"`
	IsEnglish  bool   `json:"is_english"`
}