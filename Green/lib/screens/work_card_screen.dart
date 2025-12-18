import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class WorkCardData with ChangeNotifier {
  String activityType = '';
  String workType = '';
  String location = '';
  String culture = '';
  String developmentPhase = '';
  String farmName = '';
  double area = 0.0;
  String gpsCoordinates = '';
  String date = '';

  void update({
    required String activityType,
    required String workType,
    required String location,
    required String culture,
    required String developmentPhase,
    required String farmName,
    required double area,
    required String gpsCoordinates,
    required String date,
  }) {
    this.activityType = activityType;
    this.workType = workType;
    this.location = location;
    this.culture = culture;
    this.developmentPhase = developmentPhase;
    this.farmName = farmName;
    this.area = area;
    this.gpsCoordinates = gpsCoordinates;
    this.date = date;
    notifyListeners();
  }
}

class WorkCardScreen extends StatefulWidget {
  const WorkCardScreen({super.key});

  @override
  _WorkCardScreenState createState() => _WorkCardScreenState();
}

class _WorkCardScreenState extends State<WorkCardScreen> {
  final _formKey = GlobalKey<FormState>();
  String activityType = '';
  String workType = '';
  String location = '';
  String culture = '';
  String developmentPhase = '';
  String farmName = '';
  double area = 0.0;
  String gpsCoordinates = '';
  DateTime date = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карточка работы')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Вид деятельности'),
                onChanged: (value) => activityType = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Вид работы'),
                onChanged: (value) => workType = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Место проведения'),
                onChanged: (value) => location = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Культура'),
                onChanged: (value) => culture = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Фаза развития'),
                onChanged: (value) => developmentPhase = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Название хозяйства'),
                onChanged: (value) => farmName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Площадь участка (га)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => area = double.tryParse(value) ?? 0.0,
              ),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<WorkCardData>(context, listen: false).update(
                      activityType: activityType,
                      workType: workType,
                      location: location,
                      culture: culture,
                      developmentPhase: developmentPhase,
                      farmName: farmName,
                      area: area,
                      gpsCoordinates: gpsCoordinates,
                      date: date.toIso8601String(),
                    );
                    Navigator.pushNamed(context, '/sample');
                  }
                },
                child: const Text('Сохранить карточку'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}