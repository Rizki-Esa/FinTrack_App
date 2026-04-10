package utils

import (
	"gopkg.in/gomail.v2"
	"os"
)
func SendOTPEmail(toEmail, otp string) error {

	smtpEmail := os.Getenv("SMTP_EMAIL")
	smtpPassword := os.Getenv("SMTP_PASSWORD")

	m := gomail.NewMessage()
	m.SetHeader("From", smtpEmail)
	m.SetHeader("To", toEmail)
	m.SetHeader("Subject", "Kode Reset Password")

	body := `
	<h2>Kode Reset Password</h2>
	<p>Gunakan kode berikut:</p>
	<h1>` + otp + `</h1>
	<p>Berlaku 10 menit</p>
	`

	m.SetBody("text/html", body)

	d := gomail.NewDialer(
		"smtp.gmail.com",
		587,
		smtpEmail,
		smtpPassword,
	)

	return d.DialAndSend(m)
}