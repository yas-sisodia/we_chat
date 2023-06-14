import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appBar
        appBar: AppBar(
          title: Text('Profile Screen'),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              CupertinoIcons.arrow_left,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.height * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .02),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.2),
                              child: Image.file(
                                fit: BoxFit.fill,
                                File(_image!),

                                width: mq.height * 0.2,
                                height: mq.height * 0.2,

                                // imageUrl: widget.user.image,
                                // placeholder: (context, url) => Icon(CupertinoIcons.person),
                                // errorWidget: (context, url, error) => CircleAvatar(
                                // child: Icon(CupertinoIcons.person),
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.2),
                              child: CachedNetworkImage(
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),

                      //edit image button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          color: Colors.white,
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(width: mq.width, height: mq.height * .02),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(width: mq.width, height: mq.height * .02),
                  TextFormField(
                    onSaved: (val) {
                      APIs.me.name = val ?? '';
                    },
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(),
                        hintText: 'eg. Happy Singh',
                        label: Text('Name')),
                  ),
                  SizedBox(width: mq.width, height: mq.height * .02),
                  TextFormField(
                    onSaved: (val) {
                      APIs.me.about = val ?? '';
                    },
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(),
                        hintText: 'eg. Feeling Awesome',
                        label: Text('About')),
                  ),
                  SizedBox(width: mq.width, height: mq.height * 0.06),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * 0.5, mq.height * .06)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo();
                        print("Inside Validator");
                        Dialogs.showSnackbar(context, 'Updated Successfully!!');
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 30,
                    ),
                    label: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        //add floating action button to add new user
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              //for showing progress dialog
              Dialogs.showProgressIndicator(context);
              await APIs.updateActiveStatus(false);
              //sign out from app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);
                  //for moving to homescreen
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  //replacing home screen with login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
            backgroundColor: Colors.red,
            icon: Icon(Icons.logout),
            label: Text('Logout'),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .08),
            children: [
              //pick profile picture label
              Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              // for adding some space
              SizedBox(height: mq.height * .01),
              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                          shape: CircleBorder()),
                      // onPressed: () {},
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          print(
                              'Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                          Navigator.pop(context);
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                        }
                      },
                      child: Image.asset(
                        'images/add_image.png',
                      )),
                  // take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                          shape: CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          print(
                              'Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                          Navigator.pop(context);
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                        }
                      },
                      child: Image.asset(
                        'images/camera.png',
                      ))
                ],
              )
            ],
          );
        });
  }
}
