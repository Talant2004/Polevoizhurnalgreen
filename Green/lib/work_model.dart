// work_model.dart
class Work {
  final String id;
  final String workerName;
  final String activityType;
  final String workType;
  final String location;
  final String crop;
  final String cropPhase;
  final String farmName;
  final String date;
  final double? area;
  final String? gpsCoordinates;

  Work({
    required this.id,
    required this.workerName,
    required this.activityType,
    required this.workType,
    required this.location,
    required this.crop,
    required this.cropPhase,
    required this.farmName,
    required this.date,
    this.area,
    this.gpsCoordinates,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workerName': workerName,
    'activityType': activityType,
    'workType': workType,
    'location': location,
    'crop': crop,
    'cropPhase': cropPhase,
    'farmName': farmName,
    'date': date,
    'area': area,
    'gpsCoordinates': gpsCoordinates,
  };
}

// sample_model.dart
class Sample {
  final String workId;
  final String sampleNumber;
  final double? sampleArea;
  final int pestCount;
  final String pestType;
  final String? gpsCoordinates;
  final String? photoUrl;

  Sample({
    required this.workId,
    required this.sampleNumber,
    this.sampleArea,
    required this.pestCount,
    required this.pestType,
    this.gpsCoordinates,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'workId': workId,
    'sampleNumber': sampleNumber,
    'sampleArea': sampleArea,
    'pestCount': pestCount,
    'pestType': pestType,
    'gpsCoordinates': gpsCoordinates,
    'photoUrl': photoUrl,
  };
}