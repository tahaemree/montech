# Contributing to MonTech

First off, thank you for considering contributing to MonTech! Your help is crucial in making this smart jacket application more reliable and secure for everyone.

## 1. Where do I go from here?

If you've noticed a bug or have a feature request, please open an issue first. It's generally best if you get confirmation of your bug or approval for your feature request before starting to code.

## 2. Fork & create a branch

Fork MonTech and create a branch with a descriptive name.

A good branch name would be:

```sh
git checkout -b feature/bluetooth-reconnect
```

## 3. Get the development environment running

Make sure you have Flutter SDK 3.x installed.

```bash
flutter pub get
```

Run the application on an Android device (required for testing Bluetooth features):

```bash
flutter run
```

## 4. Implement your fix or feature

Make your changes. Please ensure that you:
- Handle permissions properly (`BLUETOOTH`, `LOCATION`).
- Test with the actual Arduino/smart jacket hardware if possible.
- Update the UI following the existing Material Design theme.

## 5. Make a Pull Request

Push your changes to your fork:

```sh
git push origin feature/bluetooth-reconnect
```

Then go to GitHub and make a Pull Request.

## Coding Style

- We use **Dart format** for formatting. Run `dart format .` before committing.
- Ensure all static analysis passes by running `flutter analyze`.
