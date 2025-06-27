# ♻️ Recycle App
## 📋 Project Overview
The Recycle App is a **Flutter-based mobile and web application** designed to facilitate recycling by connecting users who want to dispose of recyclable items with administrators who manage their collection and reward them for their efforts. Users can upload item details including images, addresses, quantities, and phone numbers. Admins can review these requests, approve them, award points, and track a history of approved items.
## 🚀 Key Features
### 🧾 User Item Upload
- Users can upload details of recyclable items (e.g., Plastic, Paper, Glass, Battery).
- Includes image upload (via device gallery).
- Input fields for pickup address, quantity, and phone number.
### 🧑‍💼 User Profile & Points
- Track accumulated recycling points in a user profile.
- Points are awarded by admin approval.
- Points are convertible to BDT (Bangladeshi Taka) based on a defined rate.
### 🛠️ Admin Approval Dashboard
- View and manage pending recycling requests.
- Admins see: user name, address, phone number, category, quantity, and points.
- Approve requests to update user points and move the request to approved history.
### 📜 Approved History
- Section to view previously approved recycling requests.
- Displays: user name, category, quantity, awarded points, phone number, and approval date.
### 💻 Cross-Platform Compatibility
- Built with Flutter: runs on **Android, iOS**, and **Web** platforms.
---
## 🧪 Technologies Used

- **Flutter** – UI toolkit for cross-platform apps.
- **Firebase Firestore** – Real-time NoSQL database for user/item data.
- **Firebase Storage** – (Planned) image storage.
- **image_picker** – Plugin to pick images from the gallery.
- **random_string** – Generates unique item IDs.
- **intl** – Date formatting and display in the UI.

## 🛠️ Setup and Installation
### ✅ Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Node.js & npm (required for Firebase CLI)
### 📦 Steps
#### 1. Clone the Repository
```bash
git clone https://github.com/0mehedihasan/recycleapp-web
cd recycleapp
````
#### 2. Install Dependencies
```bash
flutter pub get
```
#### 3. Firebase Project Setup
##### Create Firebase Project
* Go to [Firebase Console](https://console.firebase.google.com/).
* Create a new project.
##### Add Android App
* Register Android App in Firebase.
* Download `google-services.json` and place it in `android/app/`.
##### Add iOS App
* Register iOS App.
* Download `GoogleService-Info.plist` and place it in `ios/Runner/`.

##### Add Web App
* Register a Web App.
* Configure Firebase in your Flutter Web project manually if necessary.
#### 4. Firestore Database Setup
##### Create Database
* In Firebase Console, go to **Firestore Database**.
* Click **Create database** → Start in **Test Mode**.
##### Example Firestore Security Rules (for development)
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
**Important**: For production, use more granular rules like:
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data
    match /users/{userId}/{documents=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Admin items
    match /adminItems/{document=**} {
      allow read, write: if request.auth != null;
    }

    // User uploaded items
    match /userUploadItems/{userId}/{documentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
## ▶️ Running the App
### 📱 For Android/iOS
```bash
flutter run
```
### 🌐 For Web
```bash
flutter run -d chrome
```
## 🗃️ Firestore Data Structure
### 🔹 `users` Collection
  * `userId` (Document ID)
  * `Name`: User’s full name
  * `Points`: Total accumulated points
### 🔹 `userUploadItems` Sub-Collection
* Path: `users/{userId}/userUploadItems/{itemId}`
  * `Image`: URL of item image
  * `Address`: Pickup address
  * `PhoneNumber`: User’s contact number
  * `Quantity`: Number of items
  * `UserId`: Uploader's ID
  * `Name`: Uploader's name
  * `Category`: Type of item (Plastic, Paper, etc.)
  * `Status`: `"Pending"` or `"Approved"`
  * `ApprovedAt`: Date/time of admin approval
### 🔹 `adminItems` Collection
* Mirrors data from `userUploadItems` for admin access.
* Path: `adminItems/{itemId}`
* Same fields as above.
## 📌 Notes
* 🔐 Firebase Storage integration is **commented out**. Needs implementation for image uploading.
* ⚠️ Use development rules only for testing. Secure your rules before production.
* 📊 Conversion rate of points to BDT is configurable in the code or admin logic.
## 🤝 Contributions
Feel free to fork the repo, make improvements, and submit pull requests!
---
## 📧 Contact
For questions, issues, or suggestions, reach out at:
**Md Mehedi Hasan**
📩 [mdmehedihasansr@gmail.com](mailto:mdmehedihasansr@gmail.com)
## 📜 License
This project is licensed under the MIT License – see the `LICENSE` file for details.
