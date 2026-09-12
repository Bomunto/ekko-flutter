# Imara

The `ekko_flutter` example: a small shop (Boutique / Panier / Compte) whose
« Commander » button fails with a 503, so there is something to report.

```sh
flutter run                                  # the pastille floats over the Flutter view
flutter run --dart-define=EKKO_OPEN_SHEET=true   # opens the report sheet at launch
```

`main()` configures ekko with the demo public key and a local API
(`192.168.1.55:3035` on iOS, `10.0.2.2:3035` on Android). App Attest needs a real
device: the bundle id is `com.bomunto.ekkoflutter`, signed with team `3TX26K8VZ8`.
