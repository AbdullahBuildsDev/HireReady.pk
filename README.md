# HireReady.pk

> Track every application. Land your dream job.

A modern job and internship application tracker built for Pakistani students.

---

## Features

### Core
- Application Tracking — Add and manage all job/internship applications
- Dashboard Stats — Real-time Total, Interview, Selected, Rejected counts
- Status Flow — Applied > Interview > Selected / Rejected
- Notes — Personal notes per application
- Deadline Tracking — Follow-up deadline per application
- Smart Notifications — Reminded 1 day before deadline
- Document Links — CV and Cover Letter Google Drive links per job
- Company Requirements — Track documents company requested

### Authentication
- Email/Password — Secure login with email verification
- Google Sign-in — One-tap Google login
- Email Verification — Only verified accounts can login
- Secure Logout — Clean session management

### Technical
- Provider — State management
- Firebase Crashlytics — Production crash reporting
- Error Boundary — Graceful error handling
- Obfuscated APK — Code protection
- System Dark Mode — Follows device theme

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform mobile framework |
| Dart | Programming language |
| Firebase Auth | Authentication (Email + Google) |
| Cloud Firestore | Real-time NoSQL database |
| Firebase Crashlytics | Crash reporting |
| Provider | State management |
| Flutter Local Notifications | Deadline reminders |
| Google Fonts | Sora + Plus Jakarta Sans |
| UUID | Unique ID generation |

---

## Project Structure
lib/
├── main.dart
├── firebase_options.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_job_screen.dart
│   └── job_detail_screen.dart
├── models/
│   └── job_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
├── providers/
│   └── job_provider.dart
└── theme/
└── app_theme.dart

---

## Database Structure
Firestore
└── jobs (collection)
└── {jobId} (document)
├── userId: string
├── company: string
├── role: string
├── status: string
├── applyDate: timestamp
├── deadline: timestamp
├── notes: string
├── cvLink: string
├── coverLetterLink: string
├── companyRequirements: string
└── createdAt: timestamp

---

## Design System

| Token | Value | Usage |
|-------|-------|-------|
| Primary | #7C6AFF | Buttons, logo |
| Background | #0F0F1A | Main background |
| Card | #1A1830 | Cards |
| Success | #4CAF50 | Selected |
| Warning | #FFC107 | Interview |
| Error | #F44336 | Rejected |
| Info | #2196F3 | Applied |

Fonts: Sora (headings) + Plus Jakarta Sans (body)

---

## Getting Started
git clone https://github.com/AbdullahBuildsDev/HireReady.pk
cd HireReady.pk
flutter pub get
flutter run
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

---

## Evaluation Checklist

| Criteria | Status |
|----------|--------|
| State Management (Provider) | Done |
| Logic-UI Separation | Done |
| Folder Structure | Done |
| Firebase Auth | Done |
| Firestore Database | Done |
| Firebase Crashlytics | Done |
| Error Boundary | Done |
| Unit Tests | Done |
| Obfuscated APK | Done |
| Email Verification | Done |
| Notifications | Done |
| Dark Theme | Done |

---

## Developer

Abdullah Awan
- GitHub: @AbdullahBuildsDev
- Degree: BS Software Engineering, 6th Semester
- Course: Mobile Application Development

---

HireReady.pk — Because your future is worth tracking