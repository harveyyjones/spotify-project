import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify_project/Business_Logic/Models/conversations_in_message_box.dart';
import 'package:spotify_project/Business_Logic/Models/user_model.dart';
import 'package:spotify_project/Business_Logic/chat_database_service.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/chat_screen.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  FirestoreDatabaseService firestoreDatabaseService =
      FirestoreDatabaseService();
  ChatDatabaseService _chatDatabaseService = ChatDatabaseService();
  ScaffoldMessengerState snackBar = ScaffoldMessengerState();

  @override
  Widget build(BuildContext context) {
    _chatDatabaseService.getConversations();
    return Scaffold(
        backgroundColor: const Color(0xfff2f9ff),
        bottomNavigationBar: BottomBar(
          selectedIndex: 3,
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 22.h),
          child: Column(
            children: [
              // ******************** LIKED PEOPLE DISPLAY *************************
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight / 35, bottom: screenHeight / 50),
                child: Container(
                  width: screenWidth / 1.1,
                  height: screenHeight / 8,
                  color: Color.fromARGB(0, 211, 176, 73),
                  child: FutureBuilder<List<UserModel>>(
                    future: firestoreDatabaseService.getLikedPeople(),
                    builder:
                        (context, AsyncSnapshot<List<UserModel>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          physics: const ScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(left: screenWidth / 60),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) => ChatScreen(
                                        snapshot.data![index].userId.toString(),
                                        snapshot.data![index].profilePhotoURL,
                                        snapshot.data![index].name.toString()),
                                  ));
                                },
                                child: CircleAvatar(
                                  minRadius: 30,
                                  maxRadius: 70.sp,
                                  foregroundImage: NetworkImage(
                                      snapshot.data![index].profilePhotoURL),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              Divider(
                color: Color.fromARGB(102, 0, 0, 0),
              ),
              Expanded(
                // Konuştuklarımın ID'lerini vesaire çektiğim kısım.
                child: FutureBuilder<List<Conversations>>(
                    future: _chatDatabaseService.getConversations(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) =>
                                FutureBuilder<UserModel?>(
                                  future: _chatDatabaseService
                                      .getUserDataForMessageBox(
                                          snapshot.data![index].receiverID),
                                  builder: (context, snapshotForUserInfo) {
                                    if (snapshotForUserInfo.hasData) {
                                      var data = snapshotForUserInfo.data;
                                      //************************** INKWELL ***********************************
                                      return InkWell(
                                        onTap: () {
                                          _chatDatabaseService
                                              .changeIsSeenStatus(snapshot
                                                  .data![index].receiverID);

                                          Navigator.of(context)
                                              .push(CupertinoPageRoute(
                                            builder: (context) {
                                              // TODO: Buraya ayar çek.
                                              return ChatScreen(
                                                data.userId.toString(),
                                                data.profilePhotoURL.toString(),
                                                data.name.toString(),
                                              );
                                            },
                                          ));
                                        },
                                        child: Container(
                                          color: snapshot.data![index].isSeen !=
                                                      null &&
                                                  snapshot.data![index].isSeen
                                              ? Colors.transparent
                                              : const Color.fromARGB(
                                                  255, 235, 233, 233),
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 9.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 18.w),
                                                        child: CircleAvatar(
                                                            maxRadius: 47,
                                                            minRadius: 20,
                                                            backgroundImage: NetworkImage(
                                                                snapshotForUserInfo
                                                                    .data!
                                                                    .profilePhotoURL
                                                                    .toString())),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.w,
                                                                bottom: 12.h),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Container(
                                                              // color: Colors.amber,
                                                              child: Text(
                                                                  data!.name
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          30.sp,
                                                                      fontFamily:
                                                                          "Calisto")),
                                                            ),
                                                            Container(
                                                              width:
                                                                  screenWidth -
                                                                      250,
                                                              // color: Colors.blue,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 20
                                                                            .h),
                                                                child: Text(
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .lastMessageSent
                                                                      .toString(),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          25,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          117,
                                                                          113,
                                                                          113),
                                                                      fontFamily:
                                                                          "Calisto"),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 12.h,
                                              ),
                                              Divider(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ));
                      } else {
                        return Container();
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}
