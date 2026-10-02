# 🏠 Student Housing Tunisia

> A modern mobile platform designed to help students in Tunisia **find housing, discover roommates, and manage their rentals** — all in one place.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Hive](https://img.shields.io/badge/Database-Hive-orange)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![License](https://img.shields.io/badge/License-Academic-lightgrey)

---

## ✨ Overview

**Student Housing Tunisia** is a Flutter mobile application inspired by platforms like Airbnb, but designed specifically for **students in Tunisia**.

The application connects students looking for accommodation with property owners offering **rooms, studios and apartments**, while also providing a dedicated **roommate matching system**.

📍 Search by city, university or location
🏠 Browse and publish properties
❤️ Save favorite listings
🤝 Find a roommate
📅 Request visits or reservations
⭐ Leave reviews
🔔 Receive notifications

---

## 🚀 Features

### 👨‍🎓 For Students

* 🔎 Search and filter housing
* 🗺️ View properties on a map
* ❤️ Manage favorites
* 📅 Request a reservation or visit
* ⭐ Rate and review properties
* 🤝 Search for roommates
* 👤 Manage personal profile

### 🏢 For Property Owners

* ➕ Publish properties
* ✏️ Edit or delete listings
* 📸 Add property photos
* 📋 Manage submitted requests
* ✅ Accept or reject reservations

### 🤝 Roommate Matching

* Create a roommate offer
* Create a roommate request
* Filter by city, university, budget and lifestyle
* Match compatible profiles
* Send and manage contact requests
* Reveal phone number after acceptance

---

## 🛠️ Tech Stack

| Technology              | Usage                |
| ----------------------- | -------------------- |
| **Flutter / Dart**      | Mobile application   |
| **Hive**                | Local NoSQL database |
| **Provider / Riverpod** | State management     |
| **OpenStreetMap**       | Maps                 |
| **flutter_map**         | Map integration      |
| **Git / GitHub**        | Version control      |
| **Material 3**          | UI design            |

The project follows a **feature-first architecture**, with data access isolated through repositories.

---

## 📱 Main Modules

```text
🔐 Authentication & Profile
        │
        ├── 👤 User Management
        │
        ├── 🏠 Property Listings
        │
        ├── 🔎 Search & Filters
        │
        ├── 🗺️ Map & Favorites
        │
        ├── 📅 Reservations
        │
        ├── ⭐ Reviews
        │
        ├── 🔔 Notifications
        │
        └── 🤝 Roommate Matching
```

---

## 🗄️ Data Storage

The application uses **Hive** as a local NoSQL database.

Main Hive boxes include:

```text
users
session
properties
property_images
amenities
property_amenities
universities
favorites
search_history
bookings
reviews
notifications
roommate_offers
roommate_requests
roommate_contacts
```

Each entity uses a unique UUID and relationships are handled through identifiers such as `owner_id` and `property_id`.

> ⚠️ **Note:** Version 1 uses local storage for academic/demo purposes. A production version would require a backend such as Firebase or Supabase.

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── theme/
│   ├── navigation/
│   ├── localization/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── profile/
│   ├── listings/
│   ├── search/
│   ├── favorites/
│   ├── bookings/
│   ├── reviews/
│   ├── notifications/
│   └── roommates/
│
├── models/
├── repositories/
└── main.dart
```

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-username/student-housing-tunisia.git
cd student-housing-tunisia
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate Hive adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the application

```bash
flutter run
```

---

## 👥 Team

Developed as a **4-member academic project**, with each member responsible for specific application modules and Hive boxes.

| Module                                   | Responsibility |
| ---------------------------------------- | -------------- |
| 🔐 Authentication & 🤝 Colocation        | Member 1       |
| 🏠 Property Listings                     | Member 2       |
| 🔎 Search, Map & Favorites               | Member 3       |
| 📅 Reservations, Reviews & Notifications | Member 4       |

---

## 📌 Project Scope

### ✅ Version 1

* Authentication
* Student & owner profiles
* Property listings
* Search & filters
* Favorites
* Maps
* Reservations
* Reviews
* Notifications
* Roommate matching
* Offline/local data

### 🔮 Future Improvements

* ☁️ Cloud backend
* 💬 Real-time messaging
* 💳 Online payments
* 🍎 iOS application
* 🔄 Real-time synchronization

Online payment, real-time messaging, backend services and iOS are explicitly outside the scope of version 1.

---

## 📄 Academic Project

This project was developed as an academic application focusing on **Flutter mobile development, local data management, modular architecture and collaborative Git/GitHub development**.

---

<p align="center">
  Made with ❤️ and Flutter 🇹🇳
</p>
