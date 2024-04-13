import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  var createdAt;
  String? userId;
  String? eMail;
  String? name;
  String? majorInfo;

  late String profilePhotoURL =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"; // Bunun veri tipini değiştirebilirim duruma göre.
  var updatedAt;
  String? biography;
  String? clinicLocation;
  String? gender;
  String? clinicName;
  String? phoneNumber;
  bool? clinicOwner;

  UserModel(
      {this.userId,
      this.name,
      this.eMail,
      this.majorInfo,
      this.clinicLocation,
      this.profilePhotoURL =
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
      this.biography,
      this.clinicName,
      var this.gender,
      var this.createdAt,
      var this.updatedAt,
      var this.phoneNumber,
      var this.clinicOwner});

  Map<String, dynamic> toMap() {
    return {
      "biography": biography ?? "",
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
      "eMail": eMail,
      "majorInfo": majorInfo,
      "clinicLocation": clinicLocation,
      "name": name,
      "clinicName": clinicName,
      "userId": userId,
      "profilePhotoURL": profilePhotoURL ?? "",
      "updatedAt": updatedAt ?? FieldValue.serverTimestamp(),
      "phoneNumber": phoneNumber,
      "clinicOwner": clinicOwner
    };
  }

// Aşağıdaki isimlendirilmiş constructor DB'den gelen mapi, UserModel nesnesine çeviriyor.
  UserModel.fromMap(Map<String, dynamic> map)
      : userId = map["userId"],
        eMail = map["eMail"],
        name = map["name"],
        majorInfo = map["majorInfo"],
        profilePhotoURL = map["profilePhotoURL"],
        clinicLocation = map["clinicLocation"],
        biography = map["biography"],
        createdAt = (map["createdAt"]),
        updatedAt = (map["updatedAt"]),
        phoneNumber = map["phoneNumber"],
        clinicName = map["clinicName"],
        clinicOwner = map["clinicOwner"];
}

extension WithGreeting on UserModel {
  String get greeting => "Hello $name";
}
