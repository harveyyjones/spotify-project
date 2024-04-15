import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/Business_Logic/Models/message_model.dart';
import 'package:spotify_project/Business_Logic/chat_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/message_box.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/screens/steppers.dart';
import 'package:spotify_project/widgets/divider_for_chat.dart';

import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(String this.userIDOfOtherUser, this.profileURL, this.name);
  String userIDOfOtherUser;
  String profileURL;
  String name;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController _scrollController = ScrollController();
  final _fireStore = FirebaseFirestore.instance;
  final _chatDBService = ChatDatabaseService();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String? messageText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textController = TextEditingController();
    return Scaffold(
      backgroundColor: Color(0xfff2f9ff),
      appBar: AppBar(
        bottom: MyDivider(),
        toolbarHeight: screenHeight / 9,
        actions: [
          Container(
            // color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50.sp,
                  backgroundImage: NetworkImage(
                    widget.profileURL,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight / 33),
                  child: Text(
                    widget.name,
                    style: GoogleFonts.poppins(
                        fontSize: 30.sp, color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: screenWidth / 2.2,
                )
              ],
            ),
          )
        ],
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth / 33),
          child: IconButton(
              iconSize: 34.sp,
              color: Colors.black,
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => MessageScreen(),
                  )),
              icon: Icon(Icons.arrow_back_ios)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // *********************** MESSAGES ************************
            Expanded(
              child: StreamBuilder(
                stream: _chatDBService.getMessagesFromStream(
                    currentUser!.uid, widget.userIDOfOtherUser),
                builder: (context, snapshot) {
                  List<Message>? allMessages = snapshot.data;

                  allMessages?.length;
                  if (snapshot.hasData) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth / 33,
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: allMessages!.length,
                        itemBuilder: (context, index) {
                          return _messageBubble(allMessages[index]);
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: screenWidth / 20,
                  right: screenWidth / 20,
                  bottom: screenHeight / 70),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // *********************** TEXT FIELD ************************
                  Expanded(
                    child: Container(
                      height: screenHeight / 15,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 12,
                                color: Color.fromARGB(36, 105, 105, 105),
                                offset: Offset(2, 4),
                                spreadRadius: 4)
                          ],
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: TextField(
                          controller: _textController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Write your message.",
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                          onChanged: (value) {
                            messageText = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth / 33,
                  ),
                  // ***************************** SEND BUTTON ******************************
                  Container(
                    height: screenHeight / 10,
                    width: screenWidth / 8,
                    child: InkWell(
                      onTap: () {
                        if (_textController.text.trim().length > 0) {
                          Message messageToSaveAndSend = Message(
                              fromWhom: currentUser!.uid,
                              date: FieldValue.serverTimestamp(),
                              isSentByMe: true,
                              message: _textController.text,
                              toWhom: widget.userIDOfOtherUser);
                          // Veritabanına mesaj gönderiliyor.

                          var result =
                              _chatDBService.sendMessage(messageToSaveAndSend);
                          result != null ? _textController.clear() : null;
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(seconds: 1),
                              curve: Curves.ease);
                        }
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              height: screenHeight / 15,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 12,
                                        color:
                                            Color.fromARGB(68, 174, 174, 174),
                                        offset: Offset(2, 4),
                                        spreadRadius: 4)
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                  shape: BoxShape.rectangle,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth / 100),
                            child: Image.asset(
                                scale: 1,
                                fit: BoxFit.fitWidth,
                                width: screenWidth / 11,
                                "lib/assets/paper_plane.png"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Konuşma balonlarını oluşturur.
Widget _messageBubble(Message allMessages) {
  Color receivedMessageColor = Color.fromARGB(255, 224, 224, 224);
  Color sentMessageColor = Color(0xff0f7bce);
  bool isSentByMe = allMessages.isSentByMe!;
  var _time;

  _displayTime(date) {
    var _formatter = DateFormat.Hm();

    date = date.toDate();
    var _formatlanmisTarih = _formatter.format(date);
    return _formatlanmisTarih;
  }

  try {
    _time = _displayTime(allMessages.date ??
        Timestamp(1,
            1)); // Burada eğer allMessages.date null ise yerine random bir TimeStamp yolladık, böylece log'da hata mesajı görmeyeceğim.
  } catch (e) {
    // Burada anlık bir hata mesajı uygulamayı durduyordu. Bu şekilde engellemiş olduk.
    print("Hata Mesajı: ${e.toString()}");
  }

  if (isSentByMe) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth / 2, top: screenHeight / 65),
      child: Container(
        // color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _time.toString(),
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: sentMessageColor,
              ),
              child: Text(
                allMessages.message!,
                style:
                    GoogleFonts.poppins(color: Colors.white, fontSize: 22.sp),
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    return Padding(
      padding: EdgeInsets.only(right: screenWidth / 2, top: screenHeight / 99),
      child: Container(
        // color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _time.toString(),
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: receivedMessageColor,
              ),
              child: Text(
                allMessages.message!,
                style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 0, 0, 0), fontSize: 22.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
