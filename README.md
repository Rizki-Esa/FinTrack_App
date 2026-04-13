# FinTrack_App

FinTrack adalah aplikasi mobile modern untuk manajemen keuangan pribadi yang dirancang dengan fokus pada **user experience, performa, dan clean architecture**.
Dibangun menggunakan **Flutter** untuk frontend dan **Golang (Gin)** untuk backend, FinTrack menghadirkan sistem yang cepat, aman, dan scalable.

---

## 📱 Preview



---

## ✨ Why FinTrack?

FinTrack bukan sekadar aplikasi pencatatan keuangan biasa. Project ini menunjukkan kemampuan dalam:

* ✅ Fullstack Mobile Development
* ✅ REST API Design & Integration
* ✅ Authentication System (JWT + OAuth)
* ✅ State Management (Provider)
* ✅ Clean Architecture & Scalable Codebase

---

## 🔥 Key Features

### 🔐 Authentication System

* Login & Register dengan Email
* Google Sign-In (OAuth 2.0)
* Secure JWT-based authentication
* Persistent login (auto session)

---

### 💸 Financial Management

* Tambah transaksi (Income & Expense)
* Kategori & deskripsi transaksi
* Delete transaksi
* Real-time data sync dengan backend

---

### 📊 Smart Dashboard

* Ringkasan saldo
* Visual chart (income vs expense)
* Recent activity tracking
* Insight sederhana untuk user

---

### 👤 User Profile

* Edit profile
* Upload foto profil
* Preferences (dark mode, language (on process))

---

## 🧠 Tech Stack

### 📱 Frontend

* Flutter
* Provider (State Management)
* Dio (Networking)
* Responsive UI System

### ⚙️ Backend

* Golang
* Gin Framework
* GORM (ORM)
* JWT Authentication
* RESTful API

### 🗄️ Database

* PostgreSQL

---

## 🏗️ Architecture Overview

### Frontend Architecture

```
Presentation (UI)
    ↓
Controller (State Management)
    ↓
Service (API Layer)
```

### Backend Architecture

```
Routes → handlers → Models → Database
```

---

## ⚙️ Getting Started

### 🔧 Backend Setup

```
cd fintrack-backend
go mod tidy
```

Buat file `.env`:

```
PORT=8080
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_NAME=fintrack
DB_PORT=5432
JWT_SECRET=your_secret_key
GOOGLE_CLIENT_ID=your_google_client_id
```

Run server:

```
go run main.go
```

---

### 📱 Frontend Setup

```
cd FinTrack_App
flutter pub get
flutter run
```

---

## 🔐 Security Implementation

* Password hashing menggunakan bcrypt
* JWT token-based authentication
* Secure storage di client
* Protected routes di backend

---

## 👨‍💻 About Me

Saya adalah developer yang fokus pada:

* Mobile App Development (Flutter)
* Backend Development (Golang, Node.js)
* System Design & Clean Architecture

Project ini dibuat sebagai bagian dari portfolio untuk menunjukkan kemampuan dalam membangun aplikasi fullstack end-to-end.

---

## ⭐ Support

Kalau project ini membantu atau menarik:

* ⭐ Star repository ini
* 🍴 Fork untuk eksplorasi
* 📩 Feel free untuk diskusi atau feedback

---
