import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  //TODO: Post paylaşma kısmını buaraya bağla.
  late final String? postOwner;
  late final List? thoseWhoLikesID;
  late final Timestamp date;
  late final String post;

  CardModel(
      {this.postOwner,
      required this.date,
      required this.post,
      this.thoseWhoLikesID});

  Map<String, dynamic> toMap() {
    return {
      "postOwner": postOwner,
      "thoseWhoLikesID": thoseWhoLikesID,
      "date": date,
      "post": post,
    };
  }

  CardModel.fromMap(Map<String, dynamic> map)
      : postOwner = map["postOwner"],
        thoseWhoLikesID = map["thoseWhoLikesID"],
        date = map["date"],
        post = map["post"];
}
