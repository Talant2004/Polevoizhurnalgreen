import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';
import 'work_card_screen.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  _SampleScreenState createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  final _formKey = GlobalKey<FormState>();
  String sampleNumber = '';
  double inspectedArea = 0.0;
  int pestCount = 0;
  String pestType = '';
  File? photo;
  String gpsCoordinates = '';
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateSampleNumber();
  }

  Future<void> _generateSampleNumber() async {
    final prefs = await SharedPreferences.getInstance();
    int lastNumber = prefs.getInt('lastSampleNumber') ?? 0;
    setState(() {
      sampleNumber = 'SAMPLE_${lastNumber + 1}';
    });
    await prefs.setInt('lastSampleNumber', lastNumber + 1);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        photo = File(pickedFile.path);
      });
    }
  }

  Future<void> _getGpsCoordinates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Включите геолокацию')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Разрешение на геолокацию отклонено')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      gpsCoordinates = '${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> _saveSample() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final workCardData = Provider.of<WorkCardData>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      String? photoUrl;
      if (photo != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('samples/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(photo!);
        photoUrl = await storageRef.getDownloadURL();
      }

      final callable = FirebaseFunctions.instance.httpsCallable('saveSample');
      final response = await callable.call({
        'sampleNumber': sampleNumber,
        'inspectedArea': inspectedArea,
        'pestCount': pestCount,
        'pestType': pestType,
        'photoUrl': photoUrl,
        'gpsCoordinates': gpsCoordinates,
        'date': DateTime.now().toIso8601String(),
        'userId': authService.currentUser?.uid,
        'workCardData': {
          'activityType': workCardData.activityType,
          'workType': workCardData.workType,
          'location': workCardData.location,
          'culture': workCardData.culture,
          'developmentPhase': workCardData.developmentPhase,
          'farmName': workCardData.farmName,
          'area': workCardData.area,
          'gpsCoordinates': workCardData.gpsCoordinates,
          'date': workCardData.date,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проба сохранена')),
      );
      _formKey.currentState!.reset();
      setState(() {
        inspectedArea = 0.0;
        pestCount = 0;
        pestType = '';
        photo = null;
        gpsCoordinates = '';
      });
      await _generateSampleNumber();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проба')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Номер пробы'),
                controller: TextEditingController(text: sampleNumber),
                onChanged: (value) => sampleNumber = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Площадь обследованного участка (га)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => inspectedArea = double.tryParse(value) ?? 0.0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Количество вредителей'),
                keyboardType: TextInputType.number,
                onChanged: (value) => pestCount = int.tryParse(value) ?? 0,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Вид вредителя'),
                items: ['Тля', 'Колорадский жук', 'Гусеница', 'Другие']
                    .map((pest) => DropdownMenuItem(value: pest, child: Text(pest)))
                    .toList(),
                onChanged: (value) => pestType = value ?? '',
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Сделать фото'),
              ),
              if (photo != null) Image.file(photo!, height: 100),
              TextFormField(
                decoration: const InputDecoration(labelText: 'GPS координаты'),
                controller: TextEditingController(text: gpsCoordinates),
                readOnly: true,
              ),
              ElevatedButton(
                onPressed: _getGpsCoordinates,
                child: const Text('Получить GPS'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveSample();
                  }
                },
                child: const Text('Сохранить пробу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}