import 'package:cloud_firestore/cloud_firestore.dart';

class Conversations {
  late final String ownerOfTheBoxID;
  late final String receiverID;
  late final bool isSeen;
  late final Timestamp date;
  late final String lastMessageSent;
  late final Timestamp timelineFromLastSight;

  Conversations(
      {required this.ownerOfTheBoxID,
      required this.receiverID,
      required this.isSeen,
      required this.date,
      required this.lastMessageSent,
      required this.timelineFromLastSight});

  Map<String, dynamic> toMap() {
    return {
      "ownerOfTheBoxID": ownerOfTheBoxID,
      "receiverID": receiverID,
      "isSeen": isSeen,
      "date": date,
      "lastMessageSent": lastMessageSent,
      "timelineFromLastNight": timelineFromLastSight
    };
  }

  Conversations.fromMap(Map<String, dynamic> map)
      : ownerOfTheBoxID = map["ownerOfTheBoxID"],
        receiverID = map["receiverID"],
        isSeen = map["isSeen"],
        date = map["date"],
        lastMessageSent = map["lastMessageSent"];
  // timelineFromLastSight = map["timelineFromLastSight"];
}
