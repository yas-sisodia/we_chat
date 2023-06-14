// import 'dart:math';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/models/chat_user.dart';

import '../models/message.dart';

class APIs {
// for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage

  static FirebaseStorage storage = FirebaseStorage.instance;

  //to return current user
  static User? get user => auth.currentUser;

  //for storing self information
  static late ChatUser me;

  //For checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user!.uid).get()).exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user!.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        print('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().toString();
    final chatUser = ChatUser(
        image: user!.photoURL.toString(),
        about: "Hey I'm using We Chat!!",
        name: user!.displayName.toString(),
        createdAt: time,
        id: user!.uid,
        isOnline: false,
        lastActive: time,
        email: user!.email.toString(),
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user!.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    // return firestore.collection('users').snapshots();
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user!.uid)
        .snapshots();
  }

  //For updating the user information
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user!.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString()
    });
  }

  //for updating profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    //storage file ref with path
    final ref = storage.ref().child('profile_picture/${user!.uid}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kB');
    });
    //updating image in firebase database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user!.uid)
        .update({'image': me.image});
  }

  //***********************    Chat Screen Related APIs   ***********

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  //useful for getting conversation id
  static String getConversationID(String id) =>
      user!.uid.hashCode <= id.hashCode
          ? '${user!.uid}_$id'
          : '${id}_${user!.uid}';
  //for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending messages
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time(also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromId: user!.uid);
    //message to send
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kB');
    });
    //updating image in firebase database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}
