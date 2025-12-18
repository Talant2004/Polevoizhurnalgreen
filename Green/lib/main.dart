// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PestControlApp());
}

class PestControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pest Control App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: AuthScreen(),
    );
  }
}

// AuthScreen
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  Future<void> _authUser() async {
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email или телефон'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authUser,
              child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin
                  ? 'Нет аккаунта? Зарегистрируйтесь'
                  : 'Есть аккаунт? Войдите'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => WorkflowScreen())),
              child: Text('Схема работы'),
            ),
          ],
        ),
      ),
    );
  }
}

// HomeScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pest Control App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => AuthScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => WorkCardScreen())),
          child: Text('Создать карточку работы'),
        ),
      ),
    );
  }
}

// WorkCardScreen
class WorkCardScreen extends StatefulWidget {
  @override
  _WorkCardScreenState createState() => _WorkCardScreenState();
}

class _WorkCardScreenState extends State<WorkCardScreen> {
  final _activityController = TextEditingController();
  final _workTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropController = TextEditingController();
  final _growthPhaseController = TextEditingController();
  final _farmController = TextEditingController();
  final _areaController = TextEditingController();
  String _gpsCoordinates = '';
  final _date = DateTime.now().toIso8601String().split('T')[0];

  Future<void> _getGpsCoordinates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Включите геолокацию')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Разрешите доступ к геолокации')));
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _gpsCoordinates = '${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> _saveWorkCard() async {
    if (_activityController.text.isEmpty ||
        _workTypeController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _cropController.text.isEmpty ||
        _growthPhaseController.text.isEmpty ||
        _farmController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _gpsCoordinates.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Заполните все поля')));
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('work_cards').add({
        'activity': _activityController.text,
        'work_type': _workTypeController.text,
        'location': _locationController.text,
        'crop': _cropController.text,
        'growth_phase': _growthPhaseController.text,
        'farm': _farmController.text,
        'area': double.parse(_areaController.text),
        'gps': _gpsCoordinates,
        'date': _date,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SampleScreen(workCardId: _gpsCoordinates)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карточка работы')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _activityController,
                decoration: InputDecoration(labelText: 'Вид деятельности'),
              ),
              TextField(
                controller: _workTypeController,
                decoration: InputDecoration(labelText: 'Вид работы'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Место проведения'),
              ),
              TextField(
                controller: _cropController,
                decoration: InputDecoration(labelText: 'Культура'),
              ),
              TextField(
                controller: _growthPhaseController,
                decoration: InputDecoration(labelText: 'Фаза развития'),
              ),
              TextField(
                controller: _farmController,
                decoration: InputDecoration(labelText: 'Название хозяйства'),
              ),
              TextField(
                controller: _areaController,
                decoration: InputDecoration(labelText: 'Площадь участка (га)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Text('GPS: $_gpsCoordinates'),
              ElevatedButton(
                onPressed: _getGpsCoordinates,
                child: Text('Получить GPS'),
              ),
              SizedBox(height: 10),
              Text('Дата: $_date'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorkCard,
                child: Text('Сохранить карточку'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SampleScreen
class SampleScreen extends StatefulWidget {
  final String workCardId;
  SampleScreen({required this.workCardId});

  @override
  _SampleScreenState createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  final _sampleNumber = 'SAMPLE_${DateTime.now().millisecondsSinceEpoch}';
  final _areaController = TextEditingController();
  final _pestCountController = TextEditingController();
  final _pestTypeController = TextEditingController();
  String _gpsCoordinates = '';
  File? _image;

  Future<void> _getGpsCoordinates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Включите геолокацию')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Разрешите доступ к геолокации')));
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _gpsCoordinates = '${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveSample() async {
    if (_areaController.text.isEmpty ||
        _pestCountController.text.isEmpty ||
        _pestTypeController.text.isEmpty ||
        _gpsCoordinates.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Заполните все поля и сделайте фото')));
      return;
    }
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('samples/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      final sampleData = {
        'sample_number': _sampleNumber,
        'work_card_id': widget.workCardId,
        'area': double.parse(_areaController.text),
        'pest_count': int.parse(_pestCountController.text),
        'pest_type': _pestTypeController.text,
        'gps': _gpsCoordinates,
        'image_url': imageUrl,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
      };

      await FirebaseFirestore.instance.collection('samples').add(sampleData);
      await _sendToGoogleSheets(sampleData);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Проба сохранена')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _sendToGoogleSheets(Map<String, dynamic> data) async {
    final credentials = ServiceAccountCredentials.fromJson({
      // Вставьте свои учетные данные Google API здесь
      "type": "service_account",
      "project_id": "your-project-id",
      "private_key_id": "your-private-key-id",
      "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
      "client_email": "your-client-email@your-project-id.iam.gserviceaccount.com",
      "client_id": "your-client-id",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/your-client-email%40your-project-id.iam.gserviceaccount.com"
    });

    final client = await clientViaServiceAccount(
        credentials, [sheets.SheetsApi.spreadsheetsScope]);
    final sheetsApi = sheets.SheetsApi(client);
    final spreadsheetId = 'your-spreadsheet-id'; // Вставьте ID таблицы Google Sheets
    final range = 'Sheet1!A:G';

    final valueRange = sheets.ValueRange.fromJson({
      'values': [[
        data['sample_number'],
        data['work_card_id'],
        data['area'],
        data['pest_count'],
        data['pest_type'],
        data['gps'],
        data['image_url'],
      ]]
    });

    await sheetsApi.spreadsheets.values.append(
        valueRange, spreadsheetId, range,
        valueInputOption: 'RAW');
    client.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Проба')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Номер пробы: $_sampleNumber'),
              TextField(
                controller: _areaController,
                decoration:
                InputDecoration(labelText: 'Площадь обследованного участка (га)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _pestCountController,
                decoration: InputDecoration(labelText: 'Количество вредителей'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _pestTypeController,
                decoration: InputDecoration(labelText: 'Вид вредителя'),
              ),
              SizedBox(height: 10),
              Text('GPS: $_gpsCoordinates'),
              ElevatedButton(
                onPressed: _getGpsCoordinates,
                child: Text('Получить GPS'),
              ),
              SizedBox(height: 10),
              _image == null
                  ? Text('Фотография не выбрана')
                  : Image.file(_image!, height: 200),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Сделать фото'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSample,
                child: Text('Сохранить пробу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// WorkflowScreen
class WorkflowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Схема работы')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Схема работы приложения:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('1. Работник заполняет карточку работы и пробы в приложении.'),
            Text('2. Данные отправляются в облако (Firebase).'),
            Text('3. Фотографии сохраняются в безопасном хранилище.'),
            Text('4. Данные о пробах записываются в Google Sheets.'),
            Text('5. Агроном или администратор проверяет данные.'),
          ],
        ),
      ),
    );
  }
}