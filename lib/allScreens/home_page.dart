import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'package:ichat_app/allModels/popup_choices.dart';
import 'package:ichat_app/allModels/user_chat.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/home_provider.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/main.dart';
import 'package:ichat_app/allScreens/settings_page.dart';
import 'package:ichat_app/utilities/debouncer.dart';
import 'package:ichat_app/utilities/utilities.dart';
import 'package:provider/src/provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncreament = 20;
  String _textSearch = "";
  bool isLoading = false;

  late String currentUserId;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searhBarTec = TextEditingController();

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Sign Out', icon: Icons.exit_to_app),
  ];

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncreament;
      });
    }
  }

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == "Sign Out") {
      handleSignOut();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: ColorConstants.themeColor,
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Canceled',
                      style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey,
        ),
        onSelected: onItemMenuPress,
        itemBuilder: (BuildContext context) {
          return choices.map((PopupChoices choice) {
            return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(color: ColorConstants.primaryColor),
                  ),
                ],
              ),
            );
          }).toList();
        });
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        //show notification
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      if (token != null) {
        homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, currentUserId, {'pushToken': token});
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: error.message.toString());
    });
  }

  void configureLocalNotification() {
    AndroidInitializationSettings initializationAndroidSettings = AndroidInitializationSettings("app_icon");
    IOSInitializationSettings initializationIOSSettings = IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationAndroidSettings,
      iOS: initializationIOSSettings,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "com.example.ichat_app",
      "iChat APP",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      notificationDetails,
      payload: null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }

    registerNotification();
    configureLocalNotification();
    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        leading: IconButton(
          icon: Switch(
            value: isWhite,
            onChanged: (value) {
              setState(() {
                isWhite = value;
                print(isWhite);
              });
            },
            activeTrackColor: Colors.grey,
            activeColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.black45,
          ),
          onPressed: () => "",
        ),
        actions: <Widget>[
          buildPopupMenu(),
        ],
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                buildSearchbar(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: homeProvider.getStreamFirestore(
                      FirestoreConstants.pathUserCollection,
                      _limit,
                      _textSearch,
                    ),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                            itemCount: snapshot.data?.docs.length,
                            controller: listScrollController,
                          );
                        } else {
                          return Center(
                            child: Text(
                              "No User found..",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
            Positioned(
              child: isLoading ? LoadingView() : SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSearchbar() {
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: ColorConstants.greyColor,
            size: 20,
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searhBarTec,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  btnClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  btnClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Search here..',
                hintStyle: TextStyle(fontSize: 13, color: ColorConstants.greyColor),
              ),
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ),
          StreamBuilder(
            stream: btnClearController.stream,
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? GestureDetector(
                      onTap: () {
                        searhBarTec.clear();
                        btnClearController.add(false);
                        setState(() {
                          _textSearch = "";
                        });
                      },
                      child: Icon(Icons.clear_rounded, color: ColorConstants.greyColor, size: 20),
                    )
                  : SizedBox.shrink();
            },
          )
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 50,
                              color: ColorConstants.greyColor,
                            );
                          },
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 50,
                          color: ColorConstants.greyColor,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '${userChat.nickname}',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            '${userChat.aboutMe}',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20),
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    peerId: userChat.id,
                    peerAvatar: userChat.photoUrl,
                    peerNickname: userChat.nickname,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.withOpacity(.2)),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
