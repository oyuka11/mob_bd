# Online Multiplayer Setup Guide

## 🎮 Features Added

Your Rock-Paper-Scissors app now supports **online multiplayer**! Players can:

-  Create game rooms with unique codes
-  Join rooms from different phones
-  Play in real-time across devices
-  See opponent's choice revealed simultaneously

## 🔧 Firebase Realtime Database Setup

To enable online multiplayer, you need to activate Firebase Realtime Database:

### Step 1: Enable Realtime Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `my-cool-project-ef700`
3. In the left sidebar, click on **Build** → **Realtime Database**
4. Click **Create Database**
5. Choose a location (preferably closest to your users)
6. Start in **Test mode** (for development)

### Step 2: Set Security Rules

For testing, use these rules (update for production):

```json
{
   "rules": {
      "game_rooms": {
         "$roomId": {
            ".read": true,
            ".write": true,
            ".indexOn": ["status", "createdAt"]
         }
      }
   }
}
```

### Step 3: Production Rules (Recommended)

For production, use stricter rules:

```json
{
   "rules": {
      "game_rooms": {
         "$roomId": {
            ".read": true,
            ".write": "auth != null",
            "player1": {
               ".validate": "newData.hasChildren(['uid', 'name'])"
            },
            "player2": {
               ".validate": "newData.hasChildren(['uid', 'name'])"
            }
         }
      }
   }
}
```

## 🎯 How to Use

### Creating a Room:

1. Open the app and login
2. Tap "2 ТОГЛОГЧ" button
3. Select "ОНЛАЙН ТОГЛОХ"
4. Tap "ӨРӨӨ ҮҮСГЭХ"
5. Share the 6-character room code with your friend

### Joining a Room:

1. Open the app and login on another device
2. Tap "2 ТОГЛОГЧ" button
3. Select "ОНЛАЙН ТОГЛОХ"
4. Enter the room code
5. Tap "ОРОХ"

### Playing:

1. Both players select Rock, Paper, or Scissors
2. Once both choose, results are revealed
3. Save the result to history
4. Play again or exit

## 📱 Testing

To test online multiplayer:

1. Use two physical devices OR
2. Use one physical device + emulator OR
3. Use Chrome DevTools device emulation for web

## 🔒 Security Notes

-  The current implementation uses test rules for easy development
-  Before releasing to production:
   -  Enable authentication requirements
   -  Add data validation rules
   -  Set up automatic cleanup for old rooms
   -  Implement rate limiting

## 🐛 Troubleshooting

**"Өрөө олдсонгүй" (Room not found):**

-  Check if Realtime Database is enabled
-  Verify room code is correct (case-sensitive)
-  Check Firebase Console for the room data

**Connection issues:**

-  Ensure both devices have internet
-  Check Firebase project configuration
-  Verify `firebase_database` dependency is installed

**Sync delays:**

-  This is normal - Firebase Realtime Database syncs in ~100-500ms
-  Check your internet connection speed

## 📦 Dependencies Used

-  `firebase_database: ^11.3.10` - For real-time data sync
-  `uuid: ^4.5.0` - For generating unique room codes

## 🎨 UI Features

-  Real-time status updates
-  Waiting room with shareable code
-  Live opponent selection indicator
-  Color-coded players (Purple vs Green)
-  Smooth animations and transitions
