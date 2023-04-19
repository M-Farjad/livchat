// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:livchat/models/message_model.dart';

import '../models/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  static Future<void> getFirebaseMessagingToken() async {
    fmessaging.requestPermission();
    await fmessaging.getToken().then((t) => {
          if (t != null) me.pushToken = t,
          log('Push Token: $t'),
        });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  //?For storing current user info
  static late ChatUser me;

  static Future<void> sendPushNotification(
      ChatUser chatUser, String message) async {
    // var url = Uri.https('example.com', 'whatsit/create');
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": message,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User_id: ${me.id}",
        },
      };
      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          body: jsonEncode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAWY6Y6f4:APA91bG9QycyfUxErXiQmDYEA1M0TOYlwrmL1urAkkjZl4hjz2z1VKdXi_oCp9-b9CCbSNDs8GojZE5mBBkmyY8-NdU4paejIYeXyivyAmHOgoCL2XhHk8O8mOfiwoB5SmMNdVnHPnKQ',
          });
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nSendNotificationErr: $e');
    }
  }

  static User get user => auth.currentUser!;
  //?For checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //?For checking if user exists or not
  static Future<bool> addNewContact(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('Data: ${data.docs}');
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log("user exists: ${data.docs.first.data()}");
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_contacts')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user doesn't exist
      return false;
    }
  }

  //?For getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //!For Updating User Status to Active
        APIs.updateActiveStatus(true);
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

  //!For getting id's of known users from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyContactsID() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_contacts')
        .snapshots();
  }

  //!For getting all users from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> contactIds) {
    log('UserIDs: $contactIds');

    return firestore
        .collection('users')
        // .where('id', isNotEqualTo: user.uid)
        .where('id', whereIn: contactIds.isEmpty ? [''] : contactIds)
        .snapshots();
  }

  //!For updating user in database
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_contacts')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
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

  //!For Getting Specific User Info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  //********
  //! Chat Screen Related APIs
  //********
  //? chats (collection) -> conversation_id (doc) -> messages (collection) -> message (doc)

  //! Useful for getting ConversationalID
  static String getConversationalID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';
  //!For getting all Messages of specific Conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationalID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //!For getting only Last Message of specific Conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationalID(user.id)}/messages/')
        .limit(1)
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final MessageModel message = MessageModel(
        msg: msg,
        toID: chatUser.id,
        read: '',
        type: type,
        fromID: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationalID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> deleteMessage(MessageModel msg) async {
    await firestore
        .collection('chats/${getConversationalID(msg.toID)}/messages/')
        .doc(msg.sent)
        .delete();
    if (msg.type == Type.image) await storage.refFromURL(msg.msg).delete();
  }

  static Future<void> updateMessage(MessageModel msg, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationalID(msg.toID)}/messages/')
        .doc(msg.sent)
        .update({'msg': updatedMsg});
  }

  //Read Double check
  static Future<void> updateMessageReadStatus(MessageModel msg) async {
    firestore
        .collection('chats/${getConversationalID(msg.fromID)}/messages/')
        .doc(msg.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Future<void> sendChatImages(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationalID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => {log('Data Transferred: ${p0.bytesTransferred / 1000}kb')});
    final imageURL = await ref.getDownloadURL();
    await sendMessage(chatUser, imageURL, Type.image);
  }
}
