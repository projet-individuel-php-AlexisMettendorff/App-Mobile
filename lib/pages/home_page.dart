import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:Locatournoi/models/city.dart';
import 'package:Locatournoi/models/device_info.dart';
import 'package:Locatournoi/pages/map_page.dart';
import 'package:Locatournoi/services/geocoder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<City> villes = [];
  City? villeChoisie;

  @override
  void initState() {
    super.initState();
    print("${DeviceInfo.latitude},${DeviceInfo.longitude}");
    getVilles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Locatournoi "),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue,
          child: Column(
            children: [
              DrawerHeader(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Tournois",
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: ajoutTournoi,
                      child: Text(
                        "Ajouter un tournoi",
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: getDataFromDatabase,
                      child: Text(
                        "Liste des tournois",
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                    ),
                  ],
                ),
              )),
              ListTile(
                onTap: null,
                title: Text(
                  "Votre liste de tournois",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: villes.length,
                      itemBuilder: (BuildContext context, int index) {
                        City ville = villes[index];
                        return ListTile(
                          onTap: null,
                          trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                supprimer(ville.name);
                              }),
                          title: Text(
                            ville.name,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [MapPage()],
          ),
        ),
      ),
    );
  }

  Future<void> getVilles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonVille = prefs.getString("villes");
    if (jsonVille != null) {
      List<dynamic> jsonList = jsonDecode(jsonVille);
      List<City> listeVille =
          jsonList.map((json) => City.fromJson(json)).toList();
      setState(() {
        villes = listeVille;
      });
    }
  }

  Future<void> ajouter(String nom, double latitude, double longitude) async {
    bool villeExistante = villes.any((city) => city.name == nom);
    if (villeExistante) {
      return;
    }

    City nouvelleVille =
        City(name: nom, latitude: latitude, longitude: longitude);
    villes.add(nouvelleVille);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList =
        villes.map((city) => city.toJson()).toList();
    await prefs.setString("villes", jsonEncode(jsonList));
    await getVilles();
  }

  Future<void> supprimer(String nom) async {
    int indexVille = villes.indexWhere((city) => city.name == nom);
    if (indexVille != -1) {
      villes.removeAt(indexVille);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> jsonList =
          villes.map((city) => city.toJson()).toList();
      await prefs.setString("villes", jsonEncode(jsonList));
      await getVilles();
    }
  }

  Future<List<Map<String, dynamic>>> getDataFromDatabase() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: '10.176.129.66',
      port: 3306,
      user: 'android',
      password: 'android',
      db: 'venues_db',
    ));

    var results = await conn.query('SELECT * FROM tournaments');
    List<Map<String, dynamic>> data = [];

    for (var row in results) {
      data.add(row.fields);
    }

    await conn.close();
    print(data);
    return data;
  }

  void main() async {
    List<Map<String, dynamic>> jsonData = await getDataFromDatabase();
    String jsonString = jsonEncode(jsonData);
    print(jsonString);
  }

  String testButton() {
    return "Test";
  }

  Future<void> ajoutTournoi() {
    City? villeSaisie;

    return showDialog(
        context: context,
        builder: (BuildContext contextDialog) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(20),
            title: Text("Ajoutez un tournoi"),
            children: [
              TypeAheadField<City>(
                itemBuilder: (context, citySuggestion) {
                  return ListTile(
                    title: Text(citySuggestion.display_name ?? "No Suggestion"),
                  );
                },
                onSelected: (citySelected) {
                  villeSaisie = citySelected;
                  print(villeSaisie.toString());
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.isNotEmpty) {
                    return await GeocoderService.searchCity(pattern);
                  } else {
                    return [];
                  }
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Entrer les informations du tournoi',
                      ));
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    if (villeSaisie != null) {
                      ajouter(villeSaisie!.name, villeSaisie!.latitude,
                          villeSaisie!.longitude);
                      Navigator.pop(contextDialog);
                    }
                  },
                  child: Text("Valider")),
            ],
          );
        });
  }
}
