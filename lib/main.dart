import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const DailyMedicineApp());
}

class DailyMedicineApp extends StatelessWidget {
  const DailyMedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DailyMedicine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DailyMedicine Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error, style: const TextStyle(color: Colors.red)),
                  ),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('Belum punya akun? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error, style: const TextStyle(color: Colors.red)),
                  ),
                FilledButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();

  User get _user => FirebaseAuth.instance.currentUser!;

  CollectionReference<Map<String, dynamic>> get _medicationsRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('medications');

  @override
  void initState() {
    super.initState();
    _syncAllReminders();
  }

  String _todayId() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}$mm$dd';
  }

  String _timeText(int hour, int minute) {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int _notificationId(String medicationId) {
    return medicationId.hashCode.abs() % 100000000;
  }

  Future<bool> _hasProofToday(String medicationId) async {
    final todayId = _todayId();
    final snap = await _medicationsRef
        .doc(medicationId)
        .collection('proofs')
        .where('dateId', isEqualTo: todayId)
        .get();
    return (snap.docs.length) > 0;
  }

  Future<int> _proofCountToday(String medicationId) async {
    final todayId = _todayId();
    final snap = await _medicationsRef
        .doc(medicationId)
        .collection('proofs')
        .where('dateId', isEqualTo: todayId)
        .get();
    return snap.docs.length;
  }

  Future<Map<int, Map<String, dynamic>>> _proofsByDoseToday(String medicationId) async {
    final todayId = _todayId();
    final snap = await _medicationsRef
        .doc(medicationId)
        .collection('proofs')
        .where('dateId', isEqualTo: todayId)
        .get();

    final proofs = <int, Map<String, dynamic>>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final doseIndex = data['doseIndex'];
      if (doseIndex is int) {
        proofs[doseIndex] = data;
      }
    }
    return proofs;
  }

  Future<bool> _proofExistsForIndex(String medicationId, int index) async {
    final todayId = _todayId();
    final snap = await _medicationsRef
        .doc(medicationId)
        .collection('proofs')
        .where('dateId', isEqualTo: todayId)
        .where('doseIndex', isEqualTo: index)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> _syncAllReminders() async {
    await NotificationService.cancelAllReminders();
    final meds = await _medicationsRef.get();
    for (final med in meds.docs) {
      await _scheduleReminderForMedication(med.id, med.data());
    }
  }

  Future<void> _cancelMedicationReminders(
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    final times = (data['times'] as List<dynamic>?)?.toList() ?? const [];

    // Legacy single reminder ID from the earlier implementation.
    await NotificationService.cancelReminder(_notificationId(medicationId));

    for (var i = 0; i < times.length; i++) {
      final notifId = _notificationId('${medicationId}_$i');
      await NotificationService.cancelReminder(notifId);
    }
  }

  Future<void> _scheduleReminderForMedication(
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    final active = data['active'] as bool? ?? true;
    final times = (data['times'] as List<dynamic>?)
            ?.map((e) => {'hour': e['hour'] as int, 'minute': e['minute'] as int})
            .toList() ??
        [ {'hour': data['hour'] as int? ?? 8, 'minute': data['minute'] as int? ?? 0} ];

    if (!active) return;

    // cancel existing reminders for this medication (all dose indices)
    for (var i = 0; i < times.length; i++) {
      final notifId = _notificationId('$medicationId\_$i');
      await NotificationService.cancelReminder(notifId);
    }

    for (var i = 0; i < times.length; i++) {
      final hour = times[i]['hour'] as int;
      final minute = times[i]['minute'] as int;
      final notifId = _notificationId('$medicationId\_$i');

      final hasProofForIndex = await _proofExistsForIndex(medicationId, i);

      var target = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );

      if (hasProofForIndex || target.isBefore(DateTime.now())) {
        target = target.add(const Duration(days: 1));
      }

      await NotificationService.scheduleReminder(
        id: notifId,
        title: 'Waktunya minum obat',
        body: '${data['name'] ?? 'Obat'} (${_timeText(hour, minute)}) belum ada bukti untuk dosis ${i + 1}.',
        scheduleAt: target,
      );
    }
  }

  Future<void> _addOrEditMedication({
    QueryDocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final nameController = TextEditingController(text: doc?.data()['name'] as String? ?? '');
    final doseController = TextEditingController(text: doc?.data()['dose'] as String? ?? '');
        List<TimeOfDay> times = (doc?.data()['times'] as List<dynamic>?)
                ?.map((e) => TimeOfDay(hour: e['hour'] as int, minute: e['minute'] as int))
                .toList() ??
            [TimeOfDay(hour: 8, minute: 0)];
    bool active = doc?.data()['active'] as bool? ?? true;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    doc == null ? 'Tambah Obat' : 'Edit Obat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama obat'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doseController,
                    decoration: const InputDecoration(labelText: 'Dosis/keterangan'),
                  ),
                  const SizedBox(height: 12),
                    Text('Jam pengingat (bisa lebih dari 1):'),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (var tIndex = 0; tIndex < times.length; tIndex++)
                          Row(
                            children: [
                              Expanded(child: Text('• ${times[tIndex].format(context)}')),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: times[tIndex],
                                  );
                                  if (picked != null) {
                                    setSheetState(() => times[tIndex] = picked);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  if (times.length > 1) {
                                    setSheetState(() => times.removeAt(tIndex));
                                  }
                                },
                              ),
                            ],
                          ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 12, minute: 0),
                            );
                            if (picked != null) {
                              setSheetState(() => times.add(picked));
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah jam'),
                        ),
                      ],
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pengingat aktif'),
                    value: active,
                    onChanged: (value) => setSheetState(() => active = value),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final dose = doseController.text.trim();
                      if (name.isEmpty || dose.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama obat dan dosis wajib diisi.')),
                        );
                        return;
                      }

                      final timesPayload = times
                          .map((t) => {'hour': t.hour, 'minute': t.minute})
                          .toList();

                      final payload = <String, dynamic>{
                        'name': name,
                        'dose': dose,
                        'times': timesPayload,
                        'doseCount': timesPayload.length,
                        'sortKey': timesPayload.isNotEmpty
                            ? timesPayload
                                .map((e) => (e['hour'] as int) * 60 + (e['minute'] as int))
                                .reduce((a, b) => a < b ? a : b)
                            : 0,
                        'active': active,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      String medicationId;
                      if (doc == null) {
                        medicationId = DateTime.now().millisecondsSinceEpoch.toString();
                        await _medicationsRef.doc(medicationId).set({
                          'id': medicationId,
                          ...payload,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      } else {
                        medicationId = doc.id;
                        await _cancelMedicationReminders(medicationId, doc.data());
                        await _medicationsRef.doc(medicationId).update(payload);
                      }

                      await _scheduleReminderForMedication(medicationId, {
                        if (doc != null) ...doc.data(),
                        ...payload,
                      });

                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext, true);
                      }
                    },
                    child: Text(doc == null ? 'Simpan Obat' : 'Update Obat'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(doc == null ? 'Obat ditambahkan.' : 'Obat diperbarui.')),
      );
    }
  }

  Future<void> _deleteMedication(String medicationId) async {
    final doc = await _medicationsRef.doc(medicationId).get();
    if (doc.exists) {
      await _cancelMedicationReminders(medicationId, doc.data() ?? {});
    }
    await _medicationsRef.doc(medicationId).delete();
  }

  Future<void> _takeProof(String medicationId, String medicationName, int doseIndex) async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo == null) {
      return;
    }

    final file = File(photo.path);
    final todayId = _todayId();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${appDir.path}/$fileName';
      await file.copy(savedPath);

      final medSnapshot = await _medicationsRef.doc(medicationId).get();
      final medData = medSnapshot.data() ?? {};
      final proofDocId = '${todayId}_$doseIndex';

      await _medicationsRef.doc(medicationId).collection('proofs').doc(proofDocId).set({
        'id': proofDocId,
        'dateId': todayId,
        'doseIndex': doseIndex,
        'medicationId': medicationId,
        'localPath': savedPath,
        'takenAt': Timestamp.now(),
        'synced': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (medSnapshot.exists) {
        await _scheduleReminderForMedication(medicationId, medData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bukti minum obat $medicationName disimpan secara lokal.')),
        );
        setState(() {});
      }
    } catch (e, st) {
      debugPrint('Local save error: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan foto secara lokal: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyMedicine'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditMedication(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Obat'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _medicationsRef.orderBy('sortKey').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final medications = snapshot.data?.docs ?? [];
          if (medications.isEmpty) {
            return const Center(
              child: Text('Belum ada obat. Tambahkan jadwal obat Anda.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = medications[index];
                final data = doc.data();
                final name = data['name'] as String? ?? '-';
                final dose = data['dose'] as String? ?? '-';
                final timesRaw = data['times'] as List<dynamic>?;
                final timesList = timesRaw
                    ?.map((e) => {'hour': e['hour'] as int, 'minute': e['minute'] as int})
                    .toList() ??
                  [ {'hour': data['hour'] as int? ?? 8, 'minute': data['minute'] as int? ?? 0} ];
                final active = data['active'] as bool? ?? true;
                final doseCount = data['doseCount'] as int? ?? timesList.length;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await _addOrEditMedication(doc: doc);
                              }
                              if (value == 'delete') {
                                await _deleteMedication(doc.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Hapus')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Dosis: $dose ($doseCount kali/hari)'),
                      Text('Jam: ${timesList.map((t) => _timeText(t['hour'] as int, t['minute'] as int)).join(', ')}'),
                      Text('Status pengingat: ${active ? 'Aktif' : 'Nonaktif'}'),
                      const SizedBox(height: 8),
                      FutureBuilder<int>(
                        future: _proofCountToday(doc.id),
                        builder: (context, proofSnapshot) {
                          final got = proofSnapshot.data ?? 0;
                          final allDone = got >= doseCount;
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Bukti hari ini: $got / $doseCount',
                                  style: TextStyle(
                                    color: allDone ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<Map<int, Map<String, dynamic>>>(
                        future: _proofsByDoseToday(doc.id),
                        builder: (context, proofMapSnapshot) {
                          final proofMap = proofMapSnapshot.data ?? const {};

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bukti per jam hari ini',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  for (var i = 0; i < timesList.length; i++)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: i == timesList.length - 1 ? 0 : 10),
                                      child: _ProofSlot(
                                        label: _timeText(timesList[i]['hour'] as int, timesList[i]['minute'] as int),
                                        proof: proofMap[i],
                                        onUploadPressed: () => _takeProof(doc.id, name, i),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProofSlot extends StatelessWidget {
  const _ProofSlot({required this.label, required this.proof, required this.onUploadPressed});

  final String label;
  final Map<String, dynamic>? proof;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    final localPath = proof?['localPath'] as String?;
    final file = localPath == null ? null : File(localPath);
    final hasImage = file != null && file.existsSync();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: hasImage
                    ? Image.file(
                        file!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Bukti tidak bisa ditampilkan'));
                        },
                      )
                    : const Center(
                        child: Text(
                          'Belum ada bukti',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 108,
          child: FilledButton(
            onPressed: onUploadPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              minimumSize: const Size(108, 44),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Upload',
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'daily_medicine_group',
          channelKey: 'daily_medicine_channel',
          channelName: 'Daily Medicine Reminder',
          channelDescription: 'Pengingat jadwal minum obat harian',
          importance: NotificationImportance.Max,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'daily_medicine_group',
          channelGroupName: 'Daily Medicine Group',
        ),
      ],
      debug: true,
    );

    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleAt,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'daily_medicine_channel',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduleAt,
        preciseAlarm: true,
      ),
    );
  }

  static Future<void> cancelReminder(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }
}
