# 🚀 FinTrack App

FinTrack adalah aplikasi modern untuk manajemen keuangan pribadi yang dapat berjalan di **Web** dan **Mobile (Android)**.
Dirancang dengan fokus pada **user experience, performa, dan clean architecture**, FinTrack menggunakan **Flutter** sebagai frontend (cross-platform) dan **Golang (Gin)** sebagai backend.

Dengan arsitektur ini, satu codebase frontend dapat digunakan untuk **multi-platform deployment**, menjadikan aplikasi lebih efisien dan scalable.

---

# Preview Aplikasi

## Authentication (Login & Register)

Tampilan autentikasi dirancang sederhana dan intuitif untuk memudahkan pengguna dalam mengakses aplikasi.

<img width="750" alt="Login Screen" src="https://github.com/user-attachments/assets/fd4226e1-22c0-4a09-849d-aa84be995af4" /><br>

<img width="750" alt="Signup Screen" src="https://github.com/user-attachments/assets/832370ac-07bd-40e3-ad85-cac2031500d4" />

## Dashboard Overview

Dashboard menampilkan ringkasan kondisi keuangan pengguna secara real-time, termasuk total pemasukan, pengeluaran, dan grafik analisis.

<img width="750" alt="Dashboard Overview" src="https://github.com/user-attachments/assets/50b85376-c6a3-459f-aee1-8a6c723a8492" />

## Financial Management

Fitur ini memungkinkan pengguna untuk mencatat transaksi serta melihat distribusi keuangan dalam bentuk visual.

<img width="750" alt="Financial Input" src="https://github.com/user-attachments/assets/d4bfb5da-8397-4a03-834b-ce2a0f16d1d9" /><br>

<img width="750" alt="Financial Chart" src="https://github.com/user-attachments/assets/125d8b07-1b08-4aac-a3c9-7d227a0f22e1" />

## Transaction History

Menampilkan daftar transaksi secara terstruktur untuk membantu pengguna melacak aktivitas keuangan.

<img width="750" alt="Transaction History" src="https://github.com/user-attachments/assets/65cdac16-c80e-4e7d-bef7-13f67f682e71" /><br>

<img width="750" alt="Transaction Detail" src="https://github.com/user-attachments/assets/66881237-ff3d-4448-bd0c-45b1bf6d84b1" />

## User Settings

Pengguna dapat mengelola profil, preferensi aplikasi, dan pengaturan lainnya sesuai kebutuhan.

<img width="750" alt="Settings Screen" src="https://github.com/user-attachments/assets/1de7189b-898f-40fb-8f9d-9e6e86f1f697" />

---

## ✨ Why FinTrack?

FinTrack bukan sekadar aplikasi pencatatan keuangan biasa. Project ini menunjukkan kemampuan dalam:

* ✅ Fullstack Cross-Platform Development (Mobile & Web)
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
* History

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
* Preferences (dark mode, language *(on process)*)

---

## 🧠 Tech Stack

### 📱 Frontend (Mobile & Web)

* Flutter (Cross-platform)
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
Routes → Handlers → Models → Database
```

---

## ⚙️ Getting Started

### 🔧 1. Backend Setup

Masuk ke folder backend:

```
cd fintrack-backend
go mod tidy
```

Buat file:

📄 `fintrack-backend/.env`

```
# APP
PORT=8080
APP_ENV=development
FRONTEND_URL=YOUR-URL or http://localhost:xxxx

# DATABASE
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_NAME=fintrack
DB_PORT=5432
DB_SSLMODE=disable

# AUTH
JWT_SECRET=your_secret_key

# EMAIL
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

Jalankan server:

```
go run main.go
```

---

### 📱 2. Frontend Setup (Mobile & Web)

Masuk ke folder project Flutter:

```
cd FinTrack_App
flutter pub get
```

Buat file 📄 `.env` pada root project Flutter:

```
API_BASE_URL=YOUR_URL
API_BASE_URL_WEB=YOUR_URL
```

### 🔍 Penjelasan

Aplikasi menggunakan **base URL yang berbeda** tergantung platform:

#### 📱 Mobile (Android / iOS)

```env
API_BASE_URL=http://192.168.x.x:8080/api
```

* Gunakan **IP address lokal (LAN)** dari komputer/server backend kamu
* Port `8080` adalah port default backend (sesuai `.env` backend)
* Contoh:

  ```
  http://192.168.93.45:8080/api
  ```

📍 Cara mengetahui IP lokal:

Windows: ipconfig
Mac/Linux: ifconfig / ip a

---

#### 🌐 Web (Browser)

```env
API_BASE_URL_WEB=http://localhost:8080/api
```

* Web berjalan di browser yang sama dengan backend
* Bisa langsung menggunakan `localhost`
* Tetap menggunakan port yang sama (`8080`)

---

### ⚠️ Catatan Penting

* Pastikan backend berjalan di:

  ```
  http://localhost:8080
  ```
* Pastikan device dan backend berada di **jaringan WiFi yang sama**
* Jika menggunakan emulator:

  * Android Emulator bisa pakai:

    ```
    http://10.0.2.2:8080/api
    ```
* Jika deploy ke server (production):

  ```env
  API_BASE_URL=https://your-domain.com/api
  API_BASE_URL_WEB=https://your-domain.com/api
  ```


#### ▶️ Run Mobile

```
flutter run
```

#### 🌐 Run Web

```
flutter run -d chrome
```




## 👨‍💻 Author

**Rizki Esa Fadillah**  
Web & Mobile Developer  

- 🌐 GitHub  : https://github.com/Rizki-Esa  
- 💼 LinkedIn: https://www.linkedin.com/in/rizki-esa-fadillah  
- 📧 Email   : rizkiiesafadillah03@gmail.com  

---

⭐ Jika project ini bermanfaat, jangan ragu untuk memberikan star pada repository ini.
