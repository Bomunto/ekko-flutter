# ekko_flutter

Signalez un bug en un tap : capture, stylo rouge, message.

A thin Flutter wrapper over the native ekko SDKs (Swift on iOS, Kotlin on Android).
No UI lives in Dart — everything visible comes from the ekko dashboard.

## Install

```yaml
dependencies:
  ekko_flutter: ^1.0.0
```

### iOS

Minimum deployment target `16.0`. The native SDK is pulled either by Swift Package
Manager (the plugin's `Package.swift` depends on `https://gitlab.com/bomunto/ekko-ios`)
or by CocoaPods — in that case add to `ios/Podfile`:

```ruby
platform :ios, '16.0'
pod 'Ekko', :git => 'https://gitlab.com/bomunto/ekko-ios.git', :tag => '1.0.1'
```

`Info.plist` keys, if you want the voice note:

- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`

App Attest needs a real team id: pass it to `configure` and set the entitlement
`com.apple.developer.devicecheck.appattest-environment`.

### Android

`minSdk 26`. The AAR comes from Maven (`com.bomunto.ekko:ekko-android`).

## Use

```dart
import 'package:ekko_flutter/ekko_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Ekko.configure(publicKey: 'pk_live_…', teamId: 'ABCDE12345');
  runApp(const MyApp());
}
```

- `Ekko.present()` opens the report sheet.
- `Ekko.identifyTester(token)` binds the session to an invited tester.
- `Ekko.handle(uri)` feeds an invitation link; returns whether ekko handled it.
