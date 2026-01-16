# Glamora

A Flutter app for managing your wardrobe digitally. Upload your clothes, get outfit suggestions, chat with friends about style, and plan what to wear.

## What it does

- **Wardrobe** - Take photos of your clothes and organize them
- **Color Analysis** - See what colors dominate your closet
- **AI Chat** - Get outfit suggestions powered by Gemini
- **Calendar** - Plan outfits for upcoming days
- **Friends** - Add friends and chat about fashion
- **Trend Matching** - Test how your style matches current trends
- **Weather** - Get suggestions based on local weather


## Tech Stack

- Flutter 3.8+
- Firebase (Auth, Firestore, Storage, Functions)
- Google Generative AI (Gemini)
- Geolocator for location
- FL Chart for graphs

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
├── pages/
│   ├── auth_gate.dart
│   ├── auth_page.dart
│   ├── home_page.dart
│   ├── wardrobe_page.dart
│   ├── photo_uploader.dart
│   ├── clothing_detail_page.dart
│   ├── color_distribution_page.dart
│   ├── calendar_page.dart
│   ├── ai_chat_page.dart
│   ├── chat_page.dart
│   ├── chat_list_page.dart
│   ├── add_friend_page.dart
│   ├── trend_match_test_page.dart
│   ├── create_username_page.dart
│   └── forgot_password_page.dart
├── services/
│   ├── auth_service.dart
│   ├── ai_service.dart
│   ├── chat_service.dart
│   ├── storage_service.dart
│   └── functions_api.dart
├── splash/
├── theme/
└── widgets/
```

## Setup

1. Clone the repo
```bash
git clone https://github.com/BekirCanTurkmen/Glamora.git
cd Glamora
```

2. Install dependencies
```bash
flutter pub get
```

3. Create a `.env` file in the root directory with your API key
```
GEMINI_API_KEY=your_gemini_api_key_here
```

4. Run
```bash
flutter run
```

> **Note:** Firebase configuration (`firebase_options.dart`) is already included in the project. If you want to use your own Firebase project:
> ```bash
> firebase login
> dart pub global activate flutterfire_cli
> flutterfire configure
> ```

## Platforms

- Android ✓
- iOS ✓
- Web (wip)
- Desktop (wip)

## Contributing

Fork it, make a branch, commit your changes, open a PR.

## Developers

- [BekirCanTurkmen](https://github.com/BekirCanTurkmen)
- [sucreistaken](https://github.com/sucreistaken)
- [ipksudeyvs](https://github.com/ipeksudeyvs)

## License

MIT
