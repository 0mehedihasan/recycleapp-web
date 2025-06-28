# ♻️ Recycle App

The **Recycle App** is a Flutter-based mobile and web application designed to simplify and encourage the recycling process. It connects users who want to dispose of recyclable items with administrators who manage collection and reward users with points that can be redeemed.
## 📽️ Demo
[![Recycle App Demo](https://img.youtube.com/vi/N53CP5FF_cQ/0.jpg)](https://youtu.be/N53CP5FF_cQ)
> 🔗 Click the image to watch the video demo on YouTube.
> 
## 👤 User Features

### 🔐 Google Sign-In
Users can securely sign in using their Google accounts.

### 🏠 Home Dashboard
After logging in, users see a dashboard featuring recycling categories:
- Plastic
- Paper
- Battery
- Glass

### 📤 Submit Recycling Request
Users can:
- Select a category
- Upload an image of the recyclable item (via device gallery)
- Enter pickup address
- Specify quantity
- Provide a phone number

Submitted requests will appear in the **Pending Requests** section until reviewed.

### 🏆 Points System
- Users earn points once an admin approves their recycling request.
- Points are shown on the **Points** page.

### 💸 Redeem Points
Users can:
- Enter the number of points to redeem
- Provide a **bKash number** for withdrawal

---

## 👨‍💼 Admin Features

### 🔐 Manual Login
Admins log in with a username and password.

### 🖥️ Admin Dashboard
Includes the following options:
- **Approval Requests** – View and manage submitted recycling requests
- **Redeem Requests** – View and approve user point redemption
- **Logout** – Sign out of admin session

### ✅ Request Approval
- Admins can view full request details submitted by users.
- Upon approval, the request moves to the **History** section.

### 💰 Redeem Approval
- Admins can view redemption requests.
- Approved redemptions are also added to the **History**.

## 🔧 Technologies Used
- **Flutter** (Mobile/Web Development)
- **Firebase Authentication** (Google Sign-In)
- **Firebase Firestore** (Database)
- **Firebase Storage** (Image upload)
- **Firebase Cloud Functions** *(optional for advanced logic)

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
