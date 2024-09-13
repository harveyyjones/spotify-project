// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_project/Business_Logic/Models/message_model.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/screens/sharePostScreen.dart' as share_screen;
import 'package:spotify_project/screens/sharePostScreen.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'Models/user_model.dart';


List allClinicOwnersList = [];

class FirestoreDatabaseService {
  final _fireStore = FirebaseFirestore.instance;
  var collection = FirebaseFirestore.instance.collection('users');

  late final FirebaseFirestore _instance = FirebaseFirestore.instance;
  var currentUserUID;
  // O anki aktif kullanıcının bilgilerini alıp nesneye çeviren metod.
  Future<UserModel> getUserData() async {
    User? user = await FirebaseAuth.instance.currentUser;

    DocumentSnapshot<Map<String, dynamic>> okunanUser =
        await FirebaseFirestore.instance.doc("users/${user?.uid}").get();
    Map<String, dynamic>? okunanUserbilgileriMap = okunanUser.data();
    UserModel okunanUserBilgileriNesne =
        UserModel.fromMap(okunanUserbilgileriMap!);
    print(okunanUserBilgileriNesne.toString());
    return okunanUserBilgileriNesne;
  }

  Future<UserModel> getUserDataForDetailPage([uid]) async {
    // Başkasının profilini incelerken veri çekmeye yarıyor.
    DocumentSnapshot<Map<String, dynamic>> okunanUser =
        await FirebaseFirestore.instance.doc("users/${uid}").get();
    Map<String, dynamic>? okunanUserbilgileriMap = okunanUser.data();
    UserModel okunanUserBilgileriNesne =
        UserModel.fromMap(okunanUserbilgileriMap!);
    print(okunanUserBilgileriNesne.name.toString());
    return okunanUserBilgileriNesne;
  }

  Future<UserModel?> getUserDataForMessageBox(uid) async {
    // Mesaj kutusunda konuştuğum insanların ID'lerini alarak kişisel bilgilerini döndüren metod.
    DocumentSnapshot<Map<String, dynamic>> okunanUser =
        await FirebaseFirestore.instance.doc("users/${uid}").get();
    Map<String, dynamic>? okunanUserbilgileriMap = await okunanUser.data();
    if (okunanUserbilgileriMap != null) {
      UserModel okunanUserBilgileriNesne =
          UserModel.fromMap(okunanUserbilgileriMap);
      print(" Fotolar :${okunanUserBilgileriNesne.name.toString()}");

      return okunanUserBilgileriNesne;
    }
    return null;
  }

  getAllUsersData() async {
// Tüm hesapları Home sayfasında display etmek için hepsini çeker.
    UserModel? okunanUserBilgileriNesne;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();

    List<DocumentSnapshot> users = querySnapshot.docs;
    var dataList = [];

    for (DocumentSnapshot user in users) {
      Map<String, dynamic> userData = user.data() as Map<String, dynamic>;
      okunanUserBilgileriNesne = UserModel.fromMap(userData);

      dataList.add(okunanUserBilgileriNesne);

      print(dataList);
    }

    // Map<String, dynamic>? okunanUserbilgileriMap = await _okunanUser.data();
    // UserModel okunanUserBilgileriNesne =
    //     await UserModel.fromMap(okunanUserbilgileriMap!);
    // print(okunanUserBilgileriNesne.toString());
    // return okunanUserBilgileriNesne;

    // var snapshot = await _instance.collection("users").get();
    // snapshot.docs.forEach((doc) {
    //   dataList.add(doc.data()["eMail"].toString());
    // });
    // print(dataList);

    return dataList;
  }

// Burda stream için verileri çekiyoruz.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getProfileData() {
    var ref = _instance.collection("users").doc(currentUser!.uid).snapshots();
    return ref;
  }

// Paylaşma tuşuna basıldıktan ve foto seçildikten sonra db'ye yazdırılan fotonun bilgilerini çeker.
  Future<DocumentSnapshot<Map<String, dynamic>>>
      getBeingSharedPostData() async {
    var paylasilanPostSayisi = await getSharedPostNumber();
    final ref = await _instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("sharedPosts")
        .doc("post$paylasilanPostSayisi")
        .get();

    return ref;
  }

  getAllSharedPosts() {
    // Tüm paylaşılan postları çeker, tabi kendi paylaştıkları.
    print("Tıklandı");
    return _instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("sharedPosts")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  getAllSharedPostsOfSomeone(uid) {
    // Tüm paylaşılan postları çeker, ancak başka bir kullanıcının.
    print("Tıklandı");
    return _instance
        .collection("users")
        .doc(uid)
        .collection("sharedPosts")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  getAllSharedPostsForCardDetails(uid) {
    print("Tıklandı");
    return _instance
        .collection("users")
        .doc(uid)
        .collection("sharedPosts")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

// Burada ilk kez register sayfasından aldığımız verileri veritabanına yolluyoruz. Öncesinde modelden geçirip map'e dönüştürüyoruz.
  Future saveUser(
      {String? biography,
      photoUrl,
      String? name,
      String? majorInfo,
      String? clinicLocation,
      String? clinicName,
      String? phoneNumber,
      bool? clinicOwner,
      var uid}) async {
    UserModel? eklenecekUser = UserModel(
        biography: biography ?? "",
        eMail: currentUser?.email ?? "",
        majorInfo: majorInfo ?? "",
        profilePhotos: photoUrl ??
            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
        name: name ?? "",
        clinicLocation: clinicLocation ?? "",
        userId: uid ?? "",
        clinicName: clinicName ?? "",
        clinicOwner: clinicOwner ?? false,
        phoneNumber: phoneNumber);

    print("Biyografi: ${eklenecekUser.biography}");
    print("E Mail: ${eklenecekUser.eMail}");
    print("Name: ${eklenecekUser.name}");
    print("Profile Photo stuff: ${eklenecekUser.profilePhotos}");
    print("UID: ${eklenecekUser.userId}");

    print("*****************************");
    print(eklenecekUser.toMap());
    await _instance.collection("users").doc(uid).set(eklenecekUser.toMap());
    DocumentSnapshot<Map<String, dynamic>> okunanUser =
        await FirebaseFirestore.instance.doc("users/${uid}").get();
    Map<String, dynamic>? okunanUserbilgileriMap = okunanUser.data();
    UserModel okunanUserBilgileriNesne =
        UserModel.fromMap(okunanUserbilgileriMap!);
    print(okunanUserBilgileriNesne.toString());
    currentUserUID = uid;
  }

  updateProfilePhoto(String imageURL) async {
    // DocumentSnapshot<Map<String, dynamic>> _okunanUser =
    collection.doc(currentUser!.uid).update({"profilePhotoURL": imageURL});

    print("--------------------------------------------");
  }

  updateName(newName) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"name": newName});
  }

  updateBiography(newBiography) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"biography": newBiography});
  }

  getName() async {
    String? name = "deafult";
    await getProfileData().forEach((element) {
      name = element.data()!["name"];
    });
    return name.toString();
  }

  void updateMajorInfo(String newMajorInfo) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"majorInfo": newMajorInfo});
  }

  void updateClinicLocation(String newLocation) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"clinicLocation": newLocation});
  }

  void updatePhoneNumber(String phoneNumber) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"phoneNumber": phoneNumber});
  }

  void updateClinicName(String clinicName) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"clinicName": clinicName});
  }

  void updateClinicOwnerStatus(bool status) {
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"clinicOwner": status});
  }

  void updateCaption(
    String newCaption,
  ) async {
    // Burada önce kaçıncı postu güncelleyeceiğini anlamak için toplam kaç post atılıdığını çekiyoruz.
    //Sonrasında (Son postu aldığımız için) güncelleme işlemi realtime olarak gerçekleşiyor.
    var postNumber = await getSharedPostNumber();
    _instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("sharedPosts")
        .doc("post$postNumber")
        .update(
      {"caption": newCaption, "uid": currentUser!.uid},
    );
  }

  Future<File?> cropImage(File imageFile) async {
    // TODO: Fotoyu kırpmadan çıkınca null hatası veriyor. Onu bir ara düzelt.
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
    return File(croppedImage!.path);
  }

  getSharedPostNumber() async {
    final QuerySnapshot docs = await _instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("sharedPosts")
        .get();

    final int docs0 = docs.docs.length;
    print("Paylaşılan foto sayısı: $docs0");

    return docs0;
  }

// Post paylaşma.
  Future sharePost(ImageSource source, context) async {
    String? downloadImageURL;
    File? _image;
    try {
      uploadImageToDatabase() async {
        UploadTask? uploadTask;
        Reference ref = await FirebaseStorage.instance
            .ref()
            .child("users")
            .child(currentUser!.uid)
            .child("post${await getSharedPostNumber()}.jpg");

        uploadTask = ref.putFile(_image!);
        await (uploadTask.whenComplete(() => ref.getDownloadURL().then((value) {
              downloadImageURL = value;
            })));
        print("Paylaşılan post URL'i : $downloadImageURL");

        await _instance
            .collection("users")
            .doc(currentUser!.uid)
            .collection("sharedPosts")
            .doc("post${await getSharedPostNumber() + 1}")
            .set({
          "sharedPost": downloadImageURL,
          "caption": "caption this",
          "timeStamp": Timestamp.now()
        }).then((value) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SharePostScreen(),
                )));
      }

      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      } else {
        File? img = File(image.path);
        img = (await cropImage(img));

        _image = img;

        uploadImageToDatabase();
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

// Çıkış yaparken
  signOut(context) async {
    await FirebaseAuth.instance.signOut();
    share_screen.callSnackbar("Signed Out", Colors.green, context);
  }

// Ana sayfadaki selamlama mesajlarında kullanmak için.
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12 && hour > 5) {
      return 'Morning';
    }
    if (hour < 17 && hour > 12) {
      return 'Afternoon';
    }
    return 'Evening';
  }

// Mesajları stream veri tipinde çekerken.
  Stream<List<Message>> getMessagesFromStream(
      String currentUserID, String userIDOfOtherUser) {
    var snapshot = _fireStore
        .collection("conversations")
        .doc("$currentUserID--$userIDOfOtherUser")
        .collection("messages")
        .orderBy("date")
        .snapshots();
    // Önce dökümanları sırayla ele almak için 1. map() metodunu çağırdık, sonra her bir dökümanı fromMap() metoduna yollamak için ikinci map metodunu çağırdık.
    return snapshot.map((event) =>
        event.docs.map((message) => Message.fromMap(message.data())).toList());
  }

// Kalıcı olarak hesap silme. Hesap silinir ama bilgiler kalır. Bilgileri de silmek için ayrı bir fonksiyon daha kullanılması gerekli.

  deleteAccount() async {
    User? user = await FirebaseAuth.instance.currentUser;
    print("Şu hesap siliniyor.. ${user!.uid}");

    try {
      user != null
          ? await user.delete().whenComplete(() {
              print("Account has been deleted.");

              // Use a different method or import the correct one
              // For example, you could use a local method or pass the context
              // Here's a placeholder comment:
              // TODO: Implement proper snackbar call or error handling

              print(
                  "User with the uid of: ${currentUser?.uid} deleted. *************************");
            })
          : print("User is null");
    } catch (e) {
      print("***********************************");
      print(e.toString());
    }
  }

  updateIsUserListening(state, url) async {
    // Buradan anlık olarak müzik dinlenip dinlenmediğini, dinleniyorsa url'sini ve başlığını çekiyorum.
    await _instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({"isUserListening": state, "songName": url});
  }

  getUserDatasToMatch(songName, amIListeningNow) async {
    print("Şu method tetiklendi: ${getUserDatasToMatch}");
    // Anlık olarak sürekli olarak o anda eşleşilen kişinin bilgilerini kullanıma hazır tutuyor.
    try {
      QuerySnapshot<Map<String, dynamic>> _okunanUser =
          await FirebaseFirestore.instance.collection("users").get();

      for (var item in _okunanUser.docs) {
        // Check if the document contains the 'songName' field
        if (item.data().containsKey('songName') &&
            songName == item["songName"]) {
          sendMatchesToDatabase(item["userId"], songName, songName);
          print("Eşleşilen kişi: ${item["name"]}");
          print("Eşleşilen kişinin uid: ${item["userId"]}");
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  sendMatchesToDatabase(uid, musicUrl, title) async {
    // Veritabına daha sonradan notifcation sayfasında kullanılmak üzere uid'leri, zamanı ve hangi şarkıyı dinlerken eşleşildiğini gönderir.
    //Böylece eşleşme gerçekleştiği anda aynı yerden veriyi çekerek ekranda gösterilebilir.
    final previousMatchesRef = _instance.doc("matches/${currentUser!.uid}");
    previousMatchesRef.collection("previousMatchesList").doc(uid).set({
      "uid": uid,
      "timeStamp": DateTime.now(),
      "url": musicUrl,
      "titleOfTheSong": title,
      "isLiked": null
    }).then((value) => print("İşlem başarılı"));
  }

  updateIsLiked(value, uidOfTheMatch) async {
    // Updates if liked to use later in the notification screen. (Or to not to show the swipe cards.)
    await _instance
        .collection("matches")
        .doc(currentUser!.uid)
        .collection("previousMatchesList")
        .doc(uidOfTheMatch)
        .update({"isLiked": value}).then(
            (value) => print("Update isLiked succesfull."));
  }

  updateIsLikedAsQuickMatch(value, uidOfTheMatch) async {
    // Updates if liked to use later in the notification screen. (Or to not to show the swipe cards.)
    final previousMatchesRef = _instance.doc("matches/${currentUser!.uid}");
    previousMatchesRef.collection("quickMatchesList").doc(uidOfTheMatch).set({
      "uid": uidOfTheMatch,
      "timeStamp": DateTime.now(),
      "isLiked": value
    }).then((value) => print("İşlem başarılı"));
  }

  getMatchesIds() async {
    print("Şu method tetiklendi getMatchesIds().");
    // Tüm eşleşmelerin Id'lerini döndürür. Daha sonra bilgileri çekmek için kullanılacak.
    List tumEslesmelerinIdsi = [];
    var previousMatchesRef = await _instance
        .collection("matches")
        .doc(currentUser!.uid)
        .collection("previousMatchesList")
        .get();
    for (var item in previousMatchesRef.docs) {
      print(item["uid"]);
      tumEslesmelerinIdsi.add(item["uid"]);
      print("Tüm eşleşmelerin olduğu kişilerin idleri: ${tumEslesmelerinIdsi}");
      return tumEslesmelerinIdsi;
    }
  }

  Future<List> getUserDataViaUId() async {
    List usersList = [];

    var previousMatchesRef = await _instance
        .collection("matches")
        .doc(currentUser!.uid)
        .collection("previousMatchesList")
        .get();
    for (var item in previousMatchesRef.docs) {
      DocumentSnapshot<Map<String, dynamic>> okunanUser =
          await FirebaseFirestore.instance.doc("users/${item["uid"]}").get();
      Map<String, dynamic>? okunanUserbilgileriMap = okunanUser.data();
      UserModel okunanUserBilgileriNesne =
          UserModel.fromMap(okunanUserbilgileriMap!);
      print(okunanUserBilgileriNesne.toString());
      usersList.add(okunanUserBilgileriNesne);
    }
    return usersList;
  }

  getTheMutualSongViaUId(uid) async {
    // Ortak bir şey dinlediğimiz kişilerle hangi şarkıda eşleştiğimizi döndüren metod.

    List tumEslesmelerinParcalari = [];
    final previousMatchesRef = await _instance
        .collection("matches")
        .doc(currentUser!.uid)
        .collection("previousMatchesList")
        .orderBy("timeStamp", descending: false)
        .get();
    for (var item in previousMatchesRef.docs) {
      if (uid == item["uid"]) {
        return item["titleOfTheSong"];
      }
      print(
          "Tüm eşleşmelerin olduğu kişilerin Şarkıları: ${tumEslesmelerinParcalari}");
    }
  }

  returnCurrentlyListeningMusicName() async {
    try {
      var isActive = false;
      var songName;
      isActive = await SpotifySdk.isSpotifyAppActive;

      var _name = SpotifySdk.subscribePlayerState();

      _name.listen((event) async {
        print("*****************************************************");
        songName = event.track!.name;
      });
      return songName.toString();
    } catch (e) {
      print("Spotify is not active or disconnected: $e");
    }
  }

  Future<List<UserModel>> getLikedPeople() async {
    List<UserModel> likedPeople = [];
  
    // Get liked people from quickMatchesList
    final quickMatchesRef = await _instance
        .collection("matches")
        .doc(currentUser!.uid)
        .collection("quickMatchesList")
        .where("isLiked", isEqualTo: true)
        .get();

    // Get liked people from previousMatchesList
    final previousMatchesRef = await _instance
        .collection("matches")
        .doc(currentUser!.uid)
        .collection("previousMatchesList")
        .where("isLiked", isEqualTo: true)
        .get();

    // Process quickMatchesList
    for (var item in quickMatchesRef.docs) {
      UserModel userModel = await getUserDataForDetailPage(item["uid"]);
      likedPeople.add(userModel);
    }

    // Process previousMatchesList
    for (var item in previousMatchesRef.docs) {
      UserModel userModel = await getUserDataForDetailPage(item["uid"]);
      likedPeople.add(userModel);
    }

    return likedPeople;
  }

  void updateActiveStatus({snapshot}) async {
    try {
      var isActive = await SpotifySdk.isSpotifyAppActive;

      var _name = SpotifySdk.subscribePlayerState();
      if (isActive) {
        _name.listen((event) async {
          print(
              "*********************  UpdateActiveStatusMethod Triggered. ********************************");
          print(isActive);
          print(event.track?.name ?? "");
          print(event.track!.imageUri.raw);
          print(event.track!.linkedFromUri);

          updateIsUserListening(isActive, event.track!.name);

          getUserDatasToMatch(event.track?.name, isActive);
        });
      }
    } catch (e) {
      print("Spotify is not active or disconnected: $e");
    }
  }

  Future<void> updateUserProfileImages({
    String? profilePhotoURL,
    List<String>? profilePhotos,
  }) async {
    // Implement the logic to update user profile images in Firestore
    // For example:
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'profilePhotoURL': profilePhotoURL,
      'profilePhotos': profilePhotos,
    });
  }
}



