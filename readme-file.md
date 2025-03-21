# RK Kitchen App

A mobile application for a home-based food business that allows customers to view the menu and place orders.

## Features

- Browse menu items by category
- View item details (description, price, image)
- Add items to cart
- Place orders with delivery/pickup options
- Receive notifications when orders are ready

## Tech Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Firestore, Cloud Functions)
- **Order Management**: Google Sheets integration
- **Notifications**: Firebase Cloud Messaging (with optional WhatsApp integration)

## Project Structure

```
lib/
├── models/       # Data models
├── screens/      # UI screens
├── services/     # API and backend services
├── utils/        # Helper functions
└── widgets/      # Reusable UI components
```

## Setup Instructions

1. Install Flutter (https://flutter.dev/docs/get-started/install)
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Configure Firebase (add your google-services.json)
5. Run `flutter run` to start the app

## Menu Update Process

The menu is synced from a Google Sheet to Firebase. To update the menu:
1. Edit the Google Sheet with new items or prices
2. The app will automatically sync with the latest data on startup

## Development Roadmap

- [x] Initial project setup
- [ ] Menu display implementation
- [ ] Order placement functionality
- [ ] Google Sheets integration
- [ ] Notification system
- [ ] Payment integration (future)