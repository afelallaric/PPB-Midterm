# DailyMedicine

Aplikasi pengingat minum obat dengan fitur:

- Login/Register (Firebase Authentication)
- Jadwal obat per user dengan jam yang diatur user
- Notifikasi pengingat bila belum ada bukti minum obat
- Kamera untuk mengambil foto bukti minum obat
- Upload bukti ke Firebase Storage
- Data Firestore dengan referensi berbasis ID dokumen

## Struktur Data Firestore (Reference by ID)

Koleksi disusun per user:

- `users/{uid}/medications/{medicationId}`
- `users/{uid}/medications/{medicationId}/proofs/{yyyymmdd}`

Contoh data obat (`medicationId` diset manual dari timestamp):

```json
{
	"id": "1714388800000",
	"name": "Paracetamol",
	"dose": "1 tablet sesudah makan",
	"hour": 20,
	"minute": 30,
	"sortKey": 1230,
	"active": true,
	"createdAt": "serverTimestamp",
	"updatedAt": "serverTimestamp"
}
```

Contoh data bukti (`proofs/{yyyymmdd}`):

```json
{
	"id": "20260429",
	"medicationId": "1714388800000",
	"imageUrl": "https://...",
	"takenAt": "timestamp",
	"createdAt": "serverTimestamp"
}
```

## Setup Firebase

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

6. Tambahkan file konfigurasi platform:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Menjalankan Aplikasi

```bash
flutter clean
flutter pub get
flutter run
```

## Catatan Platform

- Android permission kamera dan notifikasi sudah ditambahkan di `AndroidManifest.xml`.
- iOS camera usage description sudah ditambahkan di `Info.plist`.
