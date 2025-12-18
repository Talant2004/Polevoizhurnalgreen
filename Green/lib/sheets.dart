import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'work_model.dart';

class WorkEntryScreen extends StatefulWidget {
  @override
  _WorkEntryScreenState createState() => _WorkEntryScreenState();
}

class _WorkEntryScreenState extends State<WorkEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String activityType = '';
  String workType = '';
  String location = '';
  String crop = '';
  String cropPhase = '';
  String farmName = '';
  double? area;
  String? gpsCoordinates;

  Future<void> _getGpsCoordinates() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      gpsCoordinates = '${position.latitude},${position.longitude}';
    });
  }

  Future<void> _saveWork() async {
    if (_formKey.currentState!.validate()) {
      final work = Work(
        id: DateTime.now().toString(),
        workerName: 'Имя работника', // Замените на реальное имя из авторизации
        activityType: activityType,
        workType: workType,
        location: location,
        crop: crop,
        cropPhase: cropPhase,
        farmName: farmName,
        date: DateTime.now().toString(),
        area: area,
        gpsCoordinates: gpsCoordinates,
      );

      // Сохранение в Hive для офлайн-режима
      final box = await Hive.openBox('works');
      await box.put(work.id, work.toJson());

      // Переход на экран ввода проб
      Navigator.pushNamed(context, '/sample', arguments: work.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новая запись о работе')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Вид деятельности'),
                items: ['Энтомолог', 'Агроном']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => activityType = value!,
                validator: (value) => value == null ? 'Обязательно' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Вид работы'),
                onChanged: (value) => workType = value,
                validator: (value) => value!.isEmpty ? 'Обязательно' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Место проведения'),
                onChanged: (value) => location = value,
                validator: (value) => value!.isEmpty ? 'Обязательно' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Культура'),
                onChanged: (value) => crop = value,
                validator: (value) => value!.isEmpty ? 'Обязательно' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Фаза развития'),
                onChanged: (value) => cropPhase = value,
                validator: (value) => value!.isEmpty ? 'Обязательно' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Название хозяйства'),
                onChanged: (value) => farmName = value,
                validator: (value) => value!.isEmpty ? 'Обязательно' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Площадь участка (необязательно)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => area = double.tryParse(value),
              ),
              ElevatedButton(
                onPressed: _getGpsCoordinates,
                child: Text('Получить GPS'),
              ),
              Text(gpsCoordinates ?? 'GPS не получен'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWork,
                child: Text('Сохранить работу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}