// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  //?For storing current user info
  static late ChatUser me;

  static User get user => auth.currentUser!;
  //?For checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //?For getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //?For creating a user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      email: user.email.toString(),
      name: user.displayName.toString(),
      about: 'Hey There! I am using Livchat',
      createdAt: time,
      image: user.photoURL.toString(),
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //!For getting all users from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //!For updating user in database
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => {log('Data Transferred: ${p0.bytesTransferred / 1000}kb')});
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  //********
  //! Chat Screen Related APIs
  //********
  //!For getting all Messages of specific Conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    return APIs.firestore.collection('messages').snapshots();
  }
}
