package utils

import "fintrack-backend/models"

func ToUserResponse(user models.User) models.UserResponse {
	return models.UserResponse{
		ID:         user.ID,
		Name:       user.Name,
		Email:      user.Email,
		Bio:        user.Bio,
		Phone:      user.Phone,
		Image:      user.Image,
		IsDarkMode: user.IsDarkMode,
		IsEnglish:  user.IsEnglish,
	}
}