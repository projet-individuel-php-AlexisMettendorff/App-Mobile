import 'package:flutter/cupertino.dart';

class Tournament{
  String nom;
  String description;
  DateTime date;
  double prix;
  String latitude;
  String longitude;
  String nomContact;
  String emailContact;
  String photo;

  Tournament({
    required this.nom,
    required this.description,
    required this.date,
    required this.prix,
    required this.latitude,
    required this.longitude,
    required this.nomContact,
    required this.emailContact,
    required this.photo
});

  Map<String,dynamic> toJson(){
    return{
      "nom":this.nom,
      "description":this.description,
      "date":this.date,
      "prix":this.prix,
      "latitude":this.latitude,
      "longitude":this.longitude,
      "Nom du contact":this.nomContact,
      "Email du contact":this.emailContact,
      "Image":this.photo
    };
  }
  factory Tournament.fromJson(Map<String,dynamic> json){
    return Tournament(
        nom: json["nom"],
        description: json["description"],
        date: json["date"],
        prix: json["prix"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        nomContact: json["Nom du contact"],
        emailContact: json["Email du contact"],
        photo: json["Image"]
    );
  }

  @override
  String toString() {
    return 'Tournament{nom: $nom, description: $description, date: $date, prix: $prix, latitude: $latitude, longitude: $longitude, nomContact: $nomContact, emailContact: $emailContact, photo: $photo}';
  }
}