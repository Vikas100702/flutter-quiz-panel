# Flutter Quiz Panel (Web)

A comprehensive, role-based quiz management system built with Flutter Web and Firebase. This platform supports multiple user roles (Super Admin, Admin, Teacher, Student) with a dynamic, URL-based routing system.

## ✨ Features

* **Role-Based Access Control:** 4 distinct user roles with specific permissions.
    * **Super Admin:** Can manage Admins, Teachers, and Students.
    * **Admin:** Can approve new Teachers and manage Teachers/Students.
    * **Teacher:** Can create and manage "Subjects" and "Quizzes".
    * **Student:** Can register and participate in quizzes.
* **Dynamic Routing:** Uses `go_router` for URL-based navigation (e.g., `/login`, `/teacher/dashboard`).
* **Professional Auth Flow:** Full registration and login flow (Email/Password).
* **Approval System:** Teachers must be manually approved by an Admin/SuperAdmin before they can access their dashboard.
* **Quiz Creation:** Teachers can create "Subjects" (e.g., General Knowledge) and then add "Quizzes" (e.g., GK Set 1) inside them.

## 🛠️ Tech Stack

* **Framework:** Flutter (Web)
* **Backend:** Firebase (Authentication, Firestore Database)
* **State Management:** Riverpod
* **Routing:** `go_router`
* **Architecture:** 3-Layer (Data, State, UI) Repository Pattern

## 🚀 How to Run

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd flutter-quiz-panel
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Set up Firebase:**
    * Create a new Firebase project.
    * Enable **Authentication** (Email/Password).
    * Enable **Firestore Database**.
    * Run `flutterfire configure` to generate your `firebase_options.dart`.
4.  **Create Firestore Indexes:**
    This project requires two (2) composite indexes in Firestore. Create them manually:
    * **Index 1 (for Admin Approvals):**
        * **Collection:** `users`
        * **Fields:** `role` (Ascending) + `status` (Ascending)
    * **Index 2 (for Teacher Subjects):**
        * **Collection:** `subjects`
        * **Fields:** `createdBy` (Ascending) + `createdAt` (Descending)
5.  **Run the app:**
    ```bash
    flutter run -d chrome
    ```