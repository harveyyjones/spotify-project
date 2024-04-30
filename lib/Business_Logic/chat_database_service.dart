import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_project/Business_Logic/Models/conversations_in_message_box.dart';
import 'package:spotify_project/Business_Logic/Models/message_model.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/screens/steppers.dart';

class ChatDatabaseService extends FirestoreDatabaseService {
  // Burada mesajlaşma fonksiyonu ile ilgili tüm kodlar yazılır.
  final _fireStore = FirebaseFirestore.instance;

  @override
  // Mesajları QuerySnapshot türünde çeker.
  // Stream<List<Message>> getMessagesFromStream(
  //     String currentUserID, String userIDOfOtherUser) {
  //   var snapshot = _fireStore
  //       .collection("conversations")
  //       .doc("$currentUserID--$userIDOfOtherUser")
  //       .collection("messages")
  //       .orderBy("date")
  //       .snapshots();
  //   // Önce dökümanları sırayla ele almak için 1. map() metodunu çağırdık, sonra her bir dökümanı fromMap() metoduna yollamak için ikinci map metodunu çağırdık.
  //   return snapshot.map((event) =>
  //       event.docs.map((message) => Message.fromMap(message!.data())).toList());
  // }

// Mesajları veritabanına kaydeder.
  Future<bool> sendMessage(Message message) async {
    var _messageId = _fireStore.collection("conversations").doc().id;
    var _myDocumentId = message.fromWhom! + "--" + message.toWhom!;
    var _receiverDocumentId = message.toWhom! + "--" + message.fromWhom!;
    var messageInMap = message.toMap();

    // Bu metod bizim görmemiz için mesajları db'ye yazar.
    await _fireStore
        .collection("conversations")
        .doc(_myDocumentId)
        .collection("messages")
        .doc(_messageId)
        .set(messageInMap);

// Sorgu yapabilmek için aşağıdaki işlemleri yapıyoruz. İki kullanıcı için de aynısını yapacağız.
    await _fireStore.collection("conversations").doc(_myDocumentId).set({
      "ownerOfTheBoxID": message.fromWhom,
      "receiverID": message.toWhom,
      "lastMessageSent": message.message,
      "isSeen": true,
      "date": FieldValue.serverTimestamp()
    });

// Buradan aşağısı kodları karşı tarafın görmesi için db'ye yazdırır. Bu yüzden mapte aşağıdaki değişikliği yaptım.
    messageInMap.update("isSentByMe", (value) => false);
    await _fireStore
        .collection("conversations")
        .doc(_receiverDocumentId)
        .collection("messages")
        .doc(_messageId)
        .set(messageInMap);

// Sorgu yapabilmek için aşağıdaki işlemleri yapıyoruz. İki kullanıcı için de aynısını yapmış olduk.
    await _fireStore.collection("conversations").doc(_receiverDocumentId).set({
      "ownerOfTheBoxID": message.toWhom,
      "receiverID": message.fromWhom,
      "lastMessageSent": message.message,
      "isSeen": false,
      "date": FieldValue.serverTimestamp()
    });

    return true;
  }

// Mesaj kutusunda konuşmakta olduğumuz kişileri göstermek için verileri çeker.
  Future<List<Conversations>> getConversations() async {
    List<Conversations> allConversations = [];
    final _konusmalarim = await FirebaseFirestore.instance
        .collection("conversations")
        .where("ownerOfTheBoxID", isEqualTo: currentUser!.uid)
        .orderBy("date", descending: true)
        .get();

    for (var konusma in _konusmalarim.docs) {
      allConversations.add(Conversations.fromMap(konusma.data()));
    }

    return allConversations;
  }

// Sanıyorum ki bu kod mesajın okunup okunmadığı bilgisini değiştirecek. Umarım.
  changeIsSeenStatus(receiverID) async {
    var _myDocumentID = currentUser!.uid + "--" + receiverID;
    await _fireStore
        .collection("conversations")
        .doc(_myDocumentID)
        .update({"isSeen": true});
  }
}
