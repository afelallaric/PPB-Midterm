# DailyMedicine

Link video demo aplikasi: https://youtu.be/EFxrdEQ6uas

Aplikasi pengingat minum obat dengan fitur:

- Login/Register (Firebase Authentication)
- Jadwal obat per user dengan jam yang diatur user
- Notifikasi pengingat bila belum ada bukti minum obat
- Kamera untuk mengambil foto bukti minum obat
- Foto disimpan pada lokal
- Data Firestore dengan referensi berbasis ID dokumen


## Setup

1. Buat project Firebase.
2. Aktifkan Authentication metode Email/Password.
3. Aktifkan Cloud Firestore.
4. Aktifkan Firebase Storage.
5. Hubungkan app Flutter ke Firebase:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
flutterfire configure --project=asdsadasd (ini copy paste dari firebase add flutter)
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth
```

## Menjalankan Aplikasi

```bash
flutter clean
flutter pub get
flutter run
```

