# Algorand Social Media Application

Apache License

# Algochat
AlgoChat is a Cross-Platform(Android & iOS)  Mobile Application using the Algorand blockchain written in Dart and built on [Flutter](https://flutter.dev/). Dart and others. 
It actualizes many functionalities viz; chatting with friends, Posting of polls, posting of products/listings(ads), payment for purchases using Algocoins,sending and receiving Algocoins, video chatting, voice chatting, live stream of events and many others.


# Architecture

The AlgoChat Wallet built upon the [wallet-core SDK](https://github.com/.......), which provides a set of API's for the AlgoChat platform and its auxiliary services. Those services include:
- Architecture relies on the recently released community SDK, [algorand-dart](https://pub.dev/packages/algorand_dart), [Bloc](https://bloclibrary.dev/#/), 
- The relayer service for fee abstraction
- A predictable state management library and [Hive](https://docs.hivedb.dev), a lightweight and blazing fast key-value database written in pure Dart.
- Redux for state management (https://pub.dev/packages/flutter_redux)
- Dio for fetching APIs (https://pub.dev/packages/dio)
- GetIt/Injectable for Dependecy Injection (DI) (https://pub.dev/packages/get_It and https://pub.dev/packages/injectable)
- auto_route for routing (https://pub.dev/packages/auto_route)
- Multi language support (i18n)(https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl)
- Logging using [logger](https://pub.dev/packages/logger "logger") (lib/utils/log)
 

# Demo
[Download the release APK to try out AlgoChat](https://github.com/add url here) 


## Features
 - [ ] Post photo posts from camera or gallery
   * Like posts
   * Comment on posts
   * View all comments on a post
 - [ ] Profile Pages
	* Follow / Unfollow Users
	* Change image view from grid layout to feed layout
	* Add your own bio
	* Copy user public address
	* Send Algocoins to user, Etc.
 - [ ] Activity Feed showing recent likes / comments of your posts + new followers 
 - [ ] Direct Messaging (using ........ functions)
 - [ ] Video Calls(using ......... functions)
	* Custom Camera Implementation
 - [ ] Firebase Security Rules
 - [ ] Voice Calls (using ......... functions)
 - [ ] Live Video Streaming
 - [ ] Stories
 - [ ] Add others here
 
 
## Screenshots
<p>
 Let Add Image Url Here

</p>

## Dependencies

* [Flutter](https://flutter.dev/)
* [Firestore](https://github.com/flutter/plugins/tree/master/packages/cloud_firestore)
* [Image Picker](https://github.com/flutter/plugins/tree/master/packages/image_picker)
* [Google Sign In](https://github.com/flutter/plugins/tree/master/packages/google_sign_in)
* [Firebase Auth](https://github.com/flutter/plugins/tree/master/packages/firebase_auth)
* [UUID](https://github.com/Daegalus/dart-uuid)
* [Dart Image](https://github.com/brendan-duncan/image)
* [Path Provider](https://github.com/flutter/plugins/tree/master/packages/path_provider)
* [Font Awesome](https://github.com/brianegan/font_awesome_flutter)
* [Dart HTTP](https://github.com/dart-lang/http)
* [Dart Async](https://github.com/dart-lang/async)
* [Flutter Shared Preferences]()
* [Cached Network Image](https://github.com/renefloor/flutter_cached_network_image)
Add more dependency used here

## Download the App

You can download the beta version of our app from the [Google Play](https://play.google.com/store/apps/details?id=io.fuse.fusecash&hl=en) or the [App Store](https://apps.apple.com/us/app/fuse-wallet/id1491783654?ls=1)

## Getting Started

## As a developer
- Set up a Flutter environment on your machine.
   - [You can get started here](https://flutter.dev/docs/get-started/install).
   - Make sure to also [create a keystore as described here](https://flutter.dev/docs/deployment/android).
- Connect a phone or run a simulator.
- Clone the project.

      git clone https://github.com/addlink here
      cd algochat

### Configuring the environment

1. Make a copy of `.env_example` named `.env` - `cd environment && cp .env_example .env`

- For Android development, create a file at `./android/key.properties`, [as described here](https://flutter.dev/docs/deployment/android), containing the keystore path and passwords, as set up earlier.
- Run the app.

      flutter run


#### 3. Setup the firebase app

1. You'll need to create a Firebase instance. Follow the instructions at https://console.firebase.google.com.
2. Once your Firebase instance is created, you'll need to enable Google authentication.

* Go to the Firebase Console for your new instance.
* Click "Authentication" in the left-hand menu
* Click the "sign-in method" tab
* Click "Google" and enable it

3. Create Cloud Functions (to make the Feed work)
* Create a new firebase project with `firebase init`
* Copy this project's `functions/lib/index.js` to your firebase project's `functions/index.js`
* Push the function `getFeed` with `firebase deploy --only functions`  In the output, you'll see the getFeed URL, copy that.
* Replace the url in the `_getFeed` function in `feed.dart` with your cloud function url from the previous step.

_**If this does not work**  and you get the error `Error: Error parsing triggers: Cannot find module './notificationHandler'` Try following [these steps](https://github.com/mdanics/fluttergram/issues/25#issuecomment-434031430). If you are still unable to get it to work please open a new issue._

_You may need to create the neccessary index by running `firebase functions:log` and then clicking the link_

_**If you are getting no errors, but an empty feed** You must post photos or follow users with posts as the getFeed function only returns your own posts & posts from people you follow._

4. Enable the Firebase Database
* Go to the Firebase Console
* Click "Database" in the left-hand menu
* Click the Cloudstore "Create Database" button
* Select "Start in test mode" and "Enable"

5. (skip if not running on Android)

* Create an app within your Firebase instance for Android, with package name com.yourcompany.news
* Run the following command to get your SHA-1 key:

```
keytool -exportcert -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
```

* In the Firebase console, in the settings of your Android app, add your SHA-1 key by clicking "Add Fingerprint, if you want to include that to your login access".
* Follow instructions to download google-services.json
* place `google-services.json` into `/android/app/`.

6. (skip if not running on iOS)

* Create an app within your Firebase instance for iOS, with your app package name
* Follow instructions to download GoogleService-Info.plist
* Open XCode, right click the Runner folder, select the "Add Files to 'Runner'" menu, and select the GoogleService-Info.plist file to add it to /ios/Runner in XCode
* Open /ios/Runner/Info.plist in a text editor. Locate the CFBundleURLSchemes key. The second item in the array value of this key is specific to the Firebase instance. Replace it with the value for REVERSED_CLIENT_ID from GoogleService-Info.plist

Double check install instructions for both
   - Google Auth Plugin
     - https://pub.dartlang.org/packages/firebase_auth
   - Firestore Plugin
     -  https://pub.dartlang.org/packages/cloud_firestore


                        

