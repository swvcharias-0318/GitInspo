# GitInspo

GitInspo is a Flutter inspiration-sharing app with a masonry discovery feed, keyword/category search, post details, likes, share actions, saved boards, gallery uploads, and editable profiles. It uses Provider for app state and Firebase Authentication, Cloud Firestore, and Firebase Storage when configured. Without Firebase configuration, guest browsing and local demo interactions remain available.

## Run

```powershell
cd main
flutter pub get
flutter run
```

To run the widget smoke test and analyzer:

```powershell
flutter test
flutter analyze
```

## Firebase setup

1. Create a Firebase project and register the Android and iOS app IDs from `android/app/build.gradle.kts` and the iOS Runner target.
2. Enable Email/Password under Firebase Authentication, then create a Cloud Firestore database and a Cloud Storage bucket.
3. Install the FlutterFire CLI and run `flutterfire configure` from `main/`. Add the generated Android/iOS Firebase configuration to the project; `main.dart` initializes the native default Firebase app.
4. Deploy `firestore.rules` and `storage.rules` before using authenticated writes: `firebase deploy --only firestore:rules,storage`. These rules allow public post/image discovery while keeping user documents, boards, saves, and likes owner-scoped.

Firebase collections:

- `users/{uid}`: profile name, username, email, bio, profile image, follower/following counts.
- `posts/{postId}`: owner, image URL, title, description, category, tags, and creation time.
- `posts/{postId}/likes/{uid}`: per-user like records.
- `boards/{boardId}`: owner, name, description, and creation time.
- `savedPosts/{uid_postId}`: owner, post ID, board ID, and creation time.

The gallery picker is configured for iOS in `ios/Runner/Info.plist`. Android's system photo picker is supplied by `image_picker`.
