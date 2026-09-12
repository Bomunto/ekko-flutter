# ekko_flutter

Signalez un bug en un tap : capture, stylo rouge, message.

A thin Flutter wrapper over the native ekko SDKs (Swift on iOS, Kotlin on Android).
No UI lives in Dart — everything visible comes from the ekko dashboard.

## Install

```yaml
dependencies:
  ekko_flutter: ^1.1.0
```

### iOS

Minimum deployment target `16.0`. The native SDK is pulled either by Swift Package
Manager (the plugin's `Package.swift` depends on `https://github.com/bomunto/ekko-ios`)
or by CocoaPods — in that case add to `ios/Podfile`:

```ruby
platform :ios, '16.0'
pod 'Ekko', :git => 'https://github.com/bomunto/ekko-ios.git', :tag => '1.1.1'
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
- `Ekko.screen(name)` names the screen the tester is on; it lands in the report's
  timeline and in « Pour reproduire ».
- `Ekko.log(message, level: 'error')` adds a line to the report's console
  (`log | info | warn | error | debug`).
- `Ekko.recordRequest(method: 'POST', url: '…', status: 503, durationMs: 812)`
  adds a call to the report's network log — never a body, never a header.

Routes name themselves: add the observer and name your routes.

```dart
MaterialApp(
  navigatorObservers: [EkkoNavigatorObserver()],
  // …
)
```
