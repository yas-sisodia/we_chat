import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];
//for storing searched items
  final List<ChatUser> _searchList = [];
  //for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    //for setting user status to active
    APIs.updateActiveStatus(true);
    //for updating user active status according to lifecycle events
    //resume --active or online
    //pause --inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding the keyboard when a tap is detected over the screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        // or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //appBar
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                    //when search text changes then update the search list
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email ...'),
                  )
                : Text('We Chat'),
            leading: Icon(
              CupertinoIcons.home,
            ),
            //search & more vertical dots
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    if (_list.isNotEmpty) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: APIs.me)));
                    } else {
                      Dialogs.showSnackbar(context, "No user Exists!!");
                    }
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),

          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                // if some or all data is loaded then show It,
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data!.docs;
                  _list = data.map((e) => ChatUser.fromJson(e.data())).toList();
              }

              if (_list.isNotEmpty) {
                return ListView.builder(
                    itemCount: _isSearching ? _searchList.length : _list.length,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: mq.height * .01),
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                          user:
                              _isSearching ? _searchList[index] : _list[index]);
                    });
              } else {
                return Center(
                  child: Text("No Connections Found!!"),
                );
              }
            },
          ),

          //add floating action button to add new user
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                // _signOut() async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
                // }
              },
              child: Icon(Icons.add_comment_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
