# 📱 Placement Management System

A mobile-based **Placement Management System** developed using **Flutter and Dart**, with **Firebase** as the backend. The application provides students with a simple platform to view available placement opportunities, apply for jobs, track applications, and manage their profile.

The project is designed as an academic **Mobile Application Development** course project with a focus on simplicity, usability, Firebase integration, and real-time data handling.

---

## ✨ Features

### 👨‍🎓 Student Features

* 🔐 Student Registration
* 🔑 Student Login
* 🏠 Student Dashboard
* 💼 View Available Jobs
* 📝 Apply for Jobs
* 📋 View Applied Jobs
* 👤 View Student Profile
* 🚪 Logout
* 🔄 Real-time job data using Cloud Firestore

### 🔥 Firebase Features

* Firebase Authentication for user registration and login
* Cloud Firestore for storing users, jobs, and applications
* Real-time data retrieval using Firestore streams

---

## 🛠️ Technology Stack

| Technology              | Purpose                        |
| ----------------------- | ------------------------------ |
| Flutter                 | Mobile application development |
| Dart                    | Programming language           |
| Firebase Authentication | User registration and login    |
| Cloud Firestore         | Database and real-time data    |
| Material UI             | Application interface          |
| Git & GitHub            | Version control                |

---

## 📂 Project Structure

```text
placement_app/
│
├── android/
├── ios/
├── web/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── screens/
│   │   │
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   │
│   │   ├── student/
│   │   │   ├── student_dashboard.dart
│   │   │   ├── jobs_screen.dart
│   │   │   ├── applied_jobs_screen.dart
│   │   │   └── student_profile.dart
│   │
│   └── widgets/
│       └── job_card.dart
│
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## 🏗️ Application Architecture

The application follows a simple Flutter client with Firebase backend architecture.

```text
                ┌──────────────────────┐
                │       Student        │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │    Flutter Mobile    │
                │      Application     │
                └──────────┬───────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌────────────┐ ┌──────────┐
        │ Firebase │ │  Firestore │ │  Firebase│
        │   Auth   │ │  Database  │ │  Storage │
        └──────────┘ └────────────┘ └──────────┘
              │            │
              ▼            ▼
          User Login    Jobs & Applications
```

---

## 🗄️ Firebase Firestore Structure

### Users

```text
users
 └── userId
      ├── email
      └── role
```

### Jobs

```text
jobs
 └── jobId
      ├── title
      └── company
```

### Applications

```text
applications
 └── applicationId
      ├── userId
      ├── jobId
      ├── title
      └── company
```

---

## 🔄 Application Workflow

```text
Start
  ↓
Login / Register
  ↓
Firebase Authentication
  ↓
Student Dashboard
  ↓
 ┌───────────────┬─────────────────┐
 ↓               ↓                 ↓
View Jobs    Applied Jobs       Profile
 ↓
Select Job
 ↓
Apply
 ↓
Application stored in Firestore
 ↓
View Application
 ↓
End
```

---

## 🎨 UI Design

The application uses a clean and professional **light-themed interface**.

### Design Principles

* White and blue color combination
* Simple navigation
* Card-based job display
* Clear buttons and labels
* Consistent spacing
* Easy-to-use student interface
* Responsive Flutter layout

---

## 🔐 Authentication

Firebase Authentication is used to securely manage student accounts.

The authentication flow is:

```text
Registration
     ↓
Firebase Authentication
     ↓
User Account Created
     ↓
User Data Stored in Firestore
     ↓
Login
     ↓
Student Dashboard
```

---

## 💼 Job Application Process

1. Student logs into the application.
2. Student opens the **Jobs** section.
3. Available jobs are retrieved from Cloud Firestore.
4. Student selects a suitable job.
5. Student clicks **Apply**.
6. Application details are stored in the `applications` collection.
7. Student can view the applied job in **Applied Jobs**.

---

## 📋 Applied Jobs

The Applied Jobs screen retrieves applications belonging to the currently logged-in student.

Each application contains information such as:

* Job title
* Company name
* Student ID
* Job ID

This allows students to keep track of the opportunities they have applied for.

---

## 👤 Student Profile

The profile section provides basic information about the currently logged-in student.

It can be extended in the future to include:

* Full name
* Email
* Phone number
* Branch
* CGPA
* Skills
* Resume

---

## ⚙️ Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/placement-management-system.git
```

### 2. Open the Project

```bash
cd placement-management-system
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Create a Firebase project and connect the Flutter application with Firebase.

Enable:

* Firebase Authentication
* Cloud Firestore

Add the Firebase configuration required for your target platform.

### 5. Run the Application

```bash
flutter run
```

---

## 📦 Main Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core: ^2.25.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
```

> Dependency versions should match the Flutter/Dart SDK used for the project.

---

## 🧪 Testing

The application can be tested for the following operations:

| Test Case            | Expected Result                  |
| -------------------- | -------------------------------- |
| Student Registration | Account created successfully     |
| Student Login        | Dashboard opens                  |
| Invalid Login        | Error message displayed          |
| View Jobs            | Jobs retrieved from Firestore    |
| Apply for Job        | Application stored in Firestore  |
| View Applied Jobs    | Student's applications displayed |
| View Profile         | Student information displayed    |
| Logout               | User returns to login screen     |

---

## 🚀 Future Scope

The application can be extended with several features:

* Admin dashboard
* Admin job management
* Application status management
* Resume upload
* Push notifications
* Company profiles
* Job search and filtering
* Student eligibility checking
* Placement statistics
* Interview scheduling
* Email notifications
* Personalized job recommendations

---

## 🎯 Project Objectives

The main objectives of the project are:

* To develop a mobile-based placement management application.
* To simplify the job application process for students.
* To provide centralized placement information.
* To use Firebase for secure authentication and cloud data storage.
* To provide real-time access to job information.
* To demonstrate Flutter and Dart concepts learned in Mobile Application Development.

---

## 👩‍💻 Technologies Learned

Through this project, the following concepts are demonstrated:

* Flutter application development
* Dart programming
* Stateful and Stateless widgets
* Material Design
* Navigation between screens
* Forms and TextFields
* ListView and ListView.builder
* Card-based UI
* Firebase Authentication
* Cloud Firestore
* CRUD operations
* Real-time database updates

---

## 📸 Screenshots

Add screenshots of your application here:

```text
Login Screen
Student Dashboard
Jobs Screen
Apply Job
Applied Jobs
Student Profile
```

Example:

```markdown
![Login Screen](screenshots/login.png)
![Dashboard](screenshots/dashboard.png)
![Jobs](screenshots/jobs.png)
![Profile](screenshots/profile.png)
```

---

## 📌 Project Status

**Status:** Completed / Academic Project

The current version focuses on the core student placement workflow using Flutter and Firebase. Additional administrative and advanced features are planned for future development.

---

## 📄 License

This project was developed for educational and academic purposes.
