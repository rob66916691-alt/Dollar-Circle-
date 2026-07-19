# Dollar Circle Flutter App

This is the mobile-app foundation for the Dollar Circle MVP.

## Included screens

- Sign in
- Registration
- Member dashboard
- Submit a help request
- View approved requests
- Record a $1 contribution
- Member profile
- Sign out

## Requirements

Install:

- Flutter SDK
- Android Studio or Visual Studio Code
- Android emulator, iOS simulator, or a physical phone

## Create the platform folders

This package contains the application source. After extracting it, open a terminal inside the folder and run:

```bash
flutter create .
flutter pub get
```

Flutter will create the Android, iOS, web, Windows, macOS, and Linux platform folders without replacing the `lib` source files.

## Configure the API address

Open:

```text
lib/core/app_config.dart
```

Use the appropriate URL:

- Android emulator: `http://10.0.2.2:3000/api`
- iOS simulator: `http://localhost:3000/api`
- Physical phone: `http://YOUR_COMPUTER_LOCAL_IP:3000/api`

Your backend and phone must be on the same network when using a local IP.

## Run the app

Start the Dollar Circle backend first. Then run:

```bash
flutter run
```

## Current payment behavior

The "Give $1" button records a pending contribution through the backend. It does not charge a card yet. Stripe or another payment processor must be added before real money can be collected.
