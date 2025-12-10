// main.dart
// Improved UI/UX Rock-Paper-Scissors App
// Features: Gradient backgrounds, Emoji assets, Card-based layout,
// Animated feedback feel, Modern Input decoration.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// ------------------------- MAIN ENTRY -------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  Object? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    initError = e;
    print('Firebase.initializeApp error: $e\n$st');
  }

  runApp(MyInitApp(initError: initError));
}

// ------------------------- ROOT WIDGETS -------------------------

class MyInitApp extends StatelessWidget {
  final Object? initError;
  const MyInitApp({Key? key, this.initError}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Firebase холболтын алдаа!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(initError.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return MyApp();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Хайч-Чулуу-Давуу',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) return LoginPage();
        return HomePage(user: user);
      },
    );
  }
}

// ------------------------- SERVICES -------------------------

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _fire = FirebaseFirestore.instance;

  static Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    await _fire.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async => await _auth.signOut();
}

// ------------------------- LOGIN & REGISTER UI -------------------------

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF), // Purple
            Color(0xFF80D0C7), // Teal-ish
          ],
        ),
      ),
      child: child,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Text("✊✋✌️", style: TextStyle(fontSize: 40)),
                ),
                SizedBox(height: 20),
                Text(
                  "Тавтай морил",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_error != null)
                          Container(
                            padding: EdgeInsets.all(10),
                            // FIX: Error 2 fixed here (EdgeInsets.only)
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Имэйл хаяг',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Нууц үг',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: _loading
                              ? Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: Text('НЭВТРЭХ'),
                                ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RegisterPage()),
                          ),
                          child: Text('Бүртгэлгүй юу? Бүртгүүлэх'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapAuthError(e.code));
    } catch (e) {
      setState(() => _error = 'Алдаа гарлаа: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(String code) {
    if (code == 'user-not-found') return 'Ийм хэрэглэгч олдсонгүй.';
    if (code == 'wrong-password') return 'Нууц үг буруу байна.';
    if (code == 'invalid-email') return 'Имэйл хаяг буруу байна.';
    return 'Нэвтрэх алдаа: $code';
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Бүртгүүлэх')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                "Шинэ бүртгэл",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (_error != null)
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Нэр',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Имэйл',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Нууц үг',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: _loading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _register,
                                child: Text('БҮРТГҮҮЛЭХ'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Алдаа: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ------------------------- HOME PAGE -------------------------

class HomePage extends StatefulWidget {
  final User user;
  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _fire = FirebaseFirestore.instance;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final userDoc = await _fire
          .collection('users')
          .doc(widget.user.uid)
          .get();
      final name =
          userDoc.data()?['name'] as String? ??
          widget.user.displayName ??
          'Хэрэглэгч';
      if (mounted) setState(() => _displayName = name);
    } catch (e) {
      print('Name load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('RPS Game', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: Icon(Icons.history_edu, size: 28),
            tooltip: 'Түүх',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HistoryPage(uid: widget.user.uid),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, size: 28),
            onPressed: () async => await AuthService.signOut(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFFF5F7FA)],
            stops: [0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      _displayName.isNotEmpty
                          ? _displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(fontSize: 30, color: Color(0xFF6C63FF)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Сайн уу, $_displayName!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Тоглоход бэлэн үү?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Хайч, Чулуу, Давуу сонгоод\nкомпьютер эсвэл найзтайгаа өрсөлдөөрэй!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6C63FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GamePage(
                                  uid: widget.user.uid,
                                  playerName: _displayName,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.computer),
                                SizedBox(width: 10),
                                Text(
                                  "VS КОМПЬЮТЕР",
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _showTwoPlayerDialog(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people),
                                SizedBox(width: 10),
                                Text(
                                  "2 ТОГЛОГЧ",
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Сүүлийн үр дүнгүүд",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(child: _recentGamesPreview()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTwoPlayerDialog(BuildContext context) {
    final player1Ctrl = TextEditingController(text: _displayName);
    final player2Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.people, color: Color(0xFF6C63FF)),
            SizedBox(width: 10),
            Text('2 Тоглогчийн тохиргоо'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: player1Ctrl,
              decoration: InputDecoration(
                labelText: '1-р тоглогч',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: player2Ctrl,
              decoration: InputDecoration(
                labelText: '2-р тоглогч',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Цуцлах'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
            ),
            onPressed: () {
              final p1 = player1Ctrl.text.trim();
              final p2 = player2Ctrl.text.trim();
              if (p1.isEmpty || p2.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Тоглогчдын нэрийг оруулна уу!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Game2PPage(
                    player1Name: p1,
                    player2Name: p2,
                  ),
                ),
              );
            },
            child: Text('ЭХЛЭХ'),
          ),
        ],
      ),
    );
  }

  Widget _recentGamesPreview() {
    return StreamBuilder<QuerySnapshot>(
      stream: _fire
          .collection('games')
          // FIX: Error 1 fixed here (widget.user.uid)
          .where('uid', isEqualTo: widget.user.uid)
          .orderBy('playedAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError)
          return Text("Алдаа: ${snap.error}", style: TextStyle(fontSize: 10));
        if (snap.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 40, color: Colors.grey[300]),
                Text(
                  "Одоогоор тоглосон түүх алга",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );

        return ListView.builder(
          itemCount: docs.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final res = data['result'] ?? '';
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColorForResult(res).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _getEmojiForChoice(data['player']),
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                  'vs ${data['computer']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  res.toString().toUpperCase(),
                  style: TextStyle(
                    color: _getColorForResult(res),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorForResult(String res) {
    if (res == 'win') return Colors.green;
    if (res == 'lose') return Colors.red;
    return Colors.orange;
  }

  String _getEmojiForChoice(String? text) {
    if (text == 'Чулуу') return '🪨';
    if (text == 'Хайч') return '✂️';
    if (text == 'Давуу') return '📄';
    return '❓';
  }
}

// ------------------------- GAME PAGE (UI REDESIGN) -------------------------

enum MoveChoice { rock, paper, scissors }

String choiceToText(MoveChoice c) {
  switch (c) {
    case MoveChoice.rock:
      return 'Чулуу';
    case MoveChoice.paper:
      return 'Хайч';
    case MoveChoice.scissors:
      return 'Давуу';
  }
}

String choiceToEmoji(MoveChoice c) {
  switch (c) {
    case MoveChoice.rock:
      return '🪨';
    case MoveChoice.paper:
      return '📄';
    case MoveChoice.scissors:
      return '✂️';
  }
}

int evaluateRound(MoveChoice player, MoveChoice computer) {
  if (player == computer) return 0;
  if ((player == MoveChoice.rock && computer == MoveChoice.scissors) ||
      (player == MoveChoice.scissors && computer == MoveChoice.paper) ||
      (player == MoveChoice.paper && computer == MoveChoice.rock))
    return 1;
  return -1;
}

class GamePage extends StatefulWidget {
  final String uid;
  final String playerName;
  GamePage({required this.uid, required this.playerName});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  MoveChoice? _playerChoice;
  MoveChoice? _computerChoice;
  String _resultText = 'Сонголтоо хийнэ үү';
  Color _resultColor = Colors.black87;
  bool _saving = false;
  final _fire = FirebaseFirestore.instance;

  void _play(MoveChoice choice) {
    final comp = MoveChoice.values[(DateTime.now().millisecondsSinceEpoch % 3)];
    final score = evaluateRound(choice, comp);

    setState(() {
      _playerChoice = choice;
      _computerChoice = comp;
      if (score == 1) {
        _resultText = 'БАЯР ХҮРГЭЕ! ТА ЯЛЛАА';
        _resultColor = Colors.green;
      } else if (score == -1) {
        _resultText = 'ХАРАМСАЛТАЙ... ЯЛАГДЛАА';
        _resultColor = Colors.red;
      } else {
        _resultText = 'ТЭНЦЭЭ';
        _resultColor = Colors.orange;
      }
    });
  }

  Future<void> _saveResult() async {
    if (_playerChoice == null || _computerChoice == null) return;
    setState(() => _saving = true);

    final score = evaluateRound(_playerChoice!, _computerChoice!);
    final now = Timestamp.now();
    final doc = {
      'uid': widget.uid,
      'playerName': widget.playerName,
      'player': choiceToText(_playerChoice!),
      'computer': choiceToText(_computerChoice!),
      'result': score == 1
          ? 'win'
          : score == -1
          ? 'lose'
          : 'draw',
      'scoreValue': score,
      'playedAt': now,
      'playedAtServer': FieldValue.serverTimestamp(),
    };

    try {
      await _fire.collection('games').add(doc);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Амжилттай хадгаллаа!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Алдаа: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reset() {
    setState(() {
      _playerChoice = null;
      _computerChoice = null;
      _resultText = 'Сонголтоо хийнэ үү';
      _resultColor = Colors.black87;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Тоглолт')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _resultText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _resultColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDisplayColumn("Та", _playerChoice),
                      Text(
                        "VS",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      _buildDisplayColumn("Computer", _computerChoice),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            Text(
              "Сонголтоо хийнэ үү:",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameCard(MoveChoice.rock),
                _buildGameCard(MoveChoice.paper),
                _buildGameCard(MoveChoice.scissors),
              ],
            ),
            Spacer(),
            if (_playerChoice != null)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                      ),
                      onPressed: _saving ? null : _saveResult,
                      icon: _saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.save),
                      label: Text(
                        _saving ? 'Хадгалж байна...' : 'ҮР ДҮНГ ХАДГАЛАХ',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      onPressed: _reset,
                      icon: Icon(Icons.refresh, color: Color(0xFF6C63FF)),
                      label: Text(
                        'ДАХИН ТОГЛОХ',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayColumn(String label, MoveChoice? choice) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            choice != null ? choiceToEmoji(choice) : '❓',
            key: ValueKey(choice),
            style: TextStyle(fontSize: 50),
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(MoveChoice choice) {
    bool isSelected = _playerChoice == choice;
    return GestureDetector(
      onTap: () => _play(choice),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF6C63FF) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          children: [
            Text(choiceToEmoji(choice), style: TextStyle(fontSize: 40)),
            SizedBox(height: 5),
            Text(
              choiceToText(choice),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- HISTORY PAGE (CLEAN UI) -------------------------

class HistoryPage extends StatelessWidget {
  final String uid;
  HistoryPage({required this.uid});

  final _fire = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Тоглосон түүх')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fire
            .collection('games')
            .where('uid', isEqualTo: uid)
            .orderBy('playedAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text("Алдаа гарлаа."));
          if (snap.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Text('Түүх олдсонгүй'));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final playedAt = (d['playedAt'] as Timestamp?)?.toDate();
              final result = d['result'] ?? '';

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getResultColor(result).withOpacity(0.1),
                    child: Icon(
                      _getResultIcon(result),
                      color: _getResultColor(result),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        d['player'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "vs",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Text(
                        d['computer'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    playedAt != null
                        ? "${playedAt.year}-${playedAt.month}-${playedAt.day} ${playedAt.hour}:${playedAt.minute}"
                        : '',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getResultColor(result),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.toString().toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getResultColor(String res) {
    if (res == 'win') return Colors.green;
    if (res == 'lose') return Colors.red;
    return Colors.grey;
  }

  IconData _getResultIcon(String res) {
    if (res == 'win') return Icons.emoji_events;
    if (res == 'lose') return Icons.thumb_down;
    return Icons.horizontal_rule;
  }
}

class Game2PPage extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  Game2PPage({required this.player1Name, required this.player2Name});

  @override
  _Game2PPageState createState() => _Game2PPageState();
}

class _Game2PPageState extends State<Game2PPage> {
  MoveChoice? _player1Choice;
  MoveChoice? _player2Choice;
  final _fire = FirebaseFirestore.instance;
  String _resultText = '';
  Color _resultColor = Colors.black87;
  bool _saving = false;

  int evaluate2P(MoveChoice p1, MoveChoice p2) {
    if (p1 == p2) return 0;
    if ((p1 == MoveChoice.rock && p2 == MoveChoice.scissors) ||
        (p1 == MoveChoice.scissors && p2 == MoveChoice.paper) ||
        (p1 == MoveChoice.paper && p2 == MoveChoice.rock))
      return 1;
    return -1;
  }

  Future<void> _saveResult() async {
    if (_player1Choice == null || _player2Choice == null) return;
    setState(() => _saving = true);

    final score = evaluate2P(_player1Choice!, _player2Choice!);
    final doc = {
      'uid1': widget.player1Name,
      'uid2': widget.player2Name,
      'player1Choice': choiceToText(_player1Choice!),
      'player2Choice': choiceToText(_player2Choice!),
      'result': score == 1
          ? 'player1'
          : score == -1
          ? 'player2'
          : 'draw',
      'scoreValue': score,
      'playedAt': Timestamp.now(),
      'playedAtServer': FieldValue.serverTimestamp(),
    };

    try {
      await _fire.collection('games').add(doc);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Амжилттай хадгаллаа!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Алдаа: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reset() {
    setState(() {
      _player1Choice = null;
      _player2Choice = null;
      _resultText = '';
      _resultColor = Colors.black87;
    });
  }

  void _play(MoveChoice choice, int player) {
    setState(() {
      if (player == 1) _player1Choice = choice;
      if (player == 2) _player2Choice = choice;

      if (_player1Choice != null && _player2Choice != null) {
        final score = evaluate2P(_player1Choice!, _player2Choice!);
        if (score == 1) {
          _resultText = "🎉 ${widget.player1Name} ЯЛЛАА!";
          _resultColor = Colors.green;
        } else if (score == -1) {
          _resultText = "🎉 ${widget.player2Name} ЯЛЛАА!";
          _resultColor = Colors.green;
        } else {
          _resultText = "ТЭНЦЭЭ!";
          _resultColor = Colors.orange;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("2 Тоглогч")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _resultText.isEmpty ? 'Тоглогчид сонголтоо хийнэ үү' : _resultText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _resultColor,
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlayerColumn(widget.player1Name, _player1Choice, 1),
                  Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                  _buildPlayerColumn(widget.player2Name, _player2Choice, 2),
                ],
              ),
            ),
            if (_player1Choice != null && _player2Choice != null)
              Column(
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                      ),
                      onPressed: _saving ? null : _saveResult,
                      icon: _saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.save),
                      label: Text(
                        _saving ? 'Хадгалж байна...' : 'ҮР ДҮНГ ХАДГАЛАХ',
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      onPressed: _reset,
                      icon: Icon(Icons.refresh, color: Color(0xFF4CAF50)),
                      label: Text(
                        'ДАХИН ТОГЛОХ',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerColumn(String name, MoveChoice? choice, int player) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: player == 1 ? Color(0xFF6C63FF) : Color(0xFF4CAF50),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: choice != null
                    ? (player == 1 ? Color(0xFF6C63FF) : Color(0xFF4CAF50))
                    : Colors.grey.shade300,
                width: 3,
              ),
            ),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Text(
                choice != null ? choiceToEmoji(choice) : '❓',
                key: ValueKey(choice),
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Сонголтоо хийнэ үү:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: MoveChoice.values
                .map(
                  (c) => GestureDetector(
                    onTap: () => _play(c, player),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: choice == c
                            ? (player == 1 ? Color(0xFF6C63FF) : Color(0xFF4CAF50))
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: choice == c
                              ? (player == 1 ? Color(0xFF6C63FF) : Color(0xFF4CAF50))
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            choiceToEmoji(c),
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(width: 8),
                          Text(
                            choiceToText(c),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: choice == c ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
