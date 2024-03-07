import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:Locatournoi/models/device_info.dart';
import 'package:Locatournoi/pages/home_page.dart';
import 'package:Locatournoi/services/geocoder_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await location.getLocation();
  DeviceInfo.longitude = _locationData.longitude;
  DeviceInfo.latitude = _locationData.latitude;
  DeviceInfo.ville = await GeocoderService.getCityFromCoordinates(latitude: _locationData.latitude!, longitude: _locationData.longitude!);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
