# 📝 Notes App

A simple and scalable Notes Application built with Flutter using Clean Architecture principles.

This project was created to learn how real-world Flutter applications are structured, including separation of concerns, repository patterns, state management, and maintainable code organization.

---

## 🚀 Features

- ✍️ Create Notes
- 📖 View All Notes
- 🗑️ Delete Notes
- ✏️ Edit Existing Notes
- 🏗️ Clean Architecture Implementation
- 📂 Layered Project Structure
- 🔄 Repository Pattern
- 🎯 Separation of Business Logic and UI

---

## 🏛️ Architecture

This project follows Clean Architecture.

```text
lib/
│
├── core/
│   └── features/
│       └── notes/
│           ├── data/
│           │   ├── datasources/
│           │   ├── models/
│           │   └── repositories/
│           │
│           ├── domain/
│           │   ├── entities/
│           │   └── repositories/
│           │
│           └── presentation/
│               ├── screens/
│               └── widgets/
│
└── main.dart
```

### Layer Responsibilities

#### Domain Layer

Contains business rules and contracts.

- Entities
- Repository Interfaces

#### Data Layer

Handles data operations.

- Repository Implementations
- Data Sources
- Models

#### Presentation Layer

Responsible for UI and user interactions.

- Screens
- Widgets

---

## 🛠️ Tech Stack

- Flutter
- Dart
- Material Design
- Clean Architecture
- Repository Pattern
- Git & GitHub

---

## 🎯 Learning Objectives

This project helped me understand:

- Clean Architecture
- Repository Pattern
- Domain Driven Design Basics
- Flutter Navigation
- Stateful Widgets
- Form Validation
- CRUD Operations
- Git and GitHub Workflow

---

## 📦 Installation

Clone the repository:

```bash
git clone https://github.com/your-username/notes_app.git
```

Navigate to the project:

```bash
cd notes_app
```

Install dependencies:

```bash
flutter pub get
```

Run the project:

```bash
flutter run
```

---

## 🔄 Git Workflow

```bash
git add .
git commit -m "Added new feature"
git push
```

---

## 🌱 Future Improvements

- Local Database (Hive / SQLite)
- Provider State Management
- Riverpod State Management
- Dark Mode
- Search Notes
- Categories & Tags
- Cloud Sync
- Authentication
- AI-Powered Smart Note Suggestions

---

## 👨‍💻 Author

Vivek

Flutter Developer | Learning Software Engineering

---

## ⭐ Support

If you found this project useful, consider giving it a star ⭐ on GitHub.
