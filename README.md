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
## ♻️ Recycle App – Firebase Firestore Structure
### 📦 Collections & Documents

### 🔹 `users` Collection

Each document represents a registered user.

**Document ID:** `userId`

**Fields:**
- `UserId`: string (Primary Key)
- `Id`: string (Auth or internal ID)
- `Points`: string
- `email`: string
- `image`: string (Profile photo URL)
- `name`: string

#### 🔸 Sub-Collection: `userUploadItems`
**Path:** `users/{userId}/userUploadItems/{itemId}`

**Fields:**
- `Image`: string (URL)
- `Address`: string
- `PhoneNumber`: string
- `Quantity`: string
- `UserId`: string
- `Name`: string
- `Category`: string (Plastic, Paper, Battery, Glass)
- `Status`: `"Pending"` / `"Approved"`
- `ApprovedAt`: timestamp

---

### 🔹 `adminItems` Collection

**Path:** `adminItems/{itemId}`  
Mirrors data from user requests for admin access.

**Fields:** *(Same as userUploadItems)*

---

### 🔹 `redeem` Collection

**Document ID:** Auto-generated

**Fields:**
- `BDT_Equivalent`: string
- `BkashNumber`: string
- `Date`: string
- `Name`: string
- `Points`: string
- `RedeemedAt`: timestamp
- `Status`: `"Pending"` / `"Approved"` / `"Rejected"`
- `UserId`: string (FK → `users/UserId`)

---

### 🔹 `admin` Collection

**Document ID:** `id` (admin identifier)

**Fields:**
- `id`: string (Primary Key)
- `password`: string (if storing in Firestore; recommend using Firebase Auth instead)

---

## 🔗 Entity Relationships

| Relationship        | From         | To           | Type        | Description                          |
|---------------------|--------------|--------------|-------------|--------------------------------------|
| User → Request       | User.UserId  | Request.UserId | One-to-Many | A user can submit multiple requests  |
| User → Redeem        | User.UserId  | Redeem.UserId | One-to-Many | A user can redeem points multiple times |
| Admin → Request      | Admin.id     | Request       | One-to-Many | Admin approves or rejects requests   |
| Admin → Redeem       | Admin.id     | Redeem        | One-to-Many | Admin processes redemption requests  |


## 📌 Notes

- 🔐 **Security Rules**: Ensure Firestore rules restrict access based on roles (`user` vs `admin`). Do not use development rules in production.
- 📦 **Firebase Storage**: Image upload is intended to use Firebase Storage (currently commented out).
- 💰 **Points Conversion**: The rate of Points → BDT is configurable in backend logic or admin settings.
- ✅ **Admin Actions**: Admins update statuses (approved/redeemed), which reflect in user views and points.


## 🤝 Contributions
Feel free to fork the repo, make improvements, and submit pull requests!
---
## 📧 Contact
For questions, issues, or suggestions, reach out at:
**Md Mehedi Hasan**
📩 [mdmehedihasansr@gmail.com](mailto:mdmehedihasansr@gmail.com)
## 📜 License
This project is licensed under the MIT License – see the `LICENSE` file for details.
