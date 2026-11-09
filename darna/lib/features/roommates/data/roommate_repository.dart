import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/box_names.dart';
import '../models/roommate_post.dart';

class RoommateRepository {
  Box get _posts => Hive.box(BoxNames.roommatePosts);
  Box get _contacts => Hive.box(BoxNames.roommateContacts);

  ValueListenable<Box> postsListenable() => _posts.listenable();
  ValueListenable<Box> contactsListenable() => _contacts.listenable();

  List<RoommatePost> posts({String? kind, String? city, String? gender}) {
    final list = _posts.values
        .map((m) => RoommatePost.fromMap(m as Map))
        .where((p) =>
            (kind == null || p.kind == kind) &&
            (city == null || p.city == city) &&
            (gender == null || p.gender == gender))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  RoommatePost? postById(String id) {
    final map = _posts.get(id);
    return map == null ? null : RoommatePost.fromMap(map as Map);
  }

  Future<void> savePost(RoommatePost post) =>
      _posts.put(post.id, post.toMap());

  Future<void> deletePost(String id) async {
    await _posts.delete(id);
    final contactIds = _allContacts()
        .where((c) => c.postId == id)
        .map((c) => c.id)
        .toList();
    await _contacts.deleteAll(contactIds);
  }

  List<RoommateContact> _allContacts() {
    final list = _contacts.values
        .map((m) => RoommateContact.fromMap(m as Map))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<RoommateContact> received(String userId) =>
      _allContacts().where((c) => c.toUserId == userId).toList();

  List<RoommateContact> sent(String userId) =>
      _allContacts().where((c) => c.fromUserId == userId).toList();

  RoommateContact? existing(String fromUserId, String postId) {
    for (final c in _allContacts()) {
      if (c.fromUserId == fromUserId && c.postId == postId) return c;
    }
    return null;
  }

  Future<void> sendContact({
    required RoommatePost post,
    required String fromUserId,
    required String message,
  }) {
    final contact = RoommateContact(
      id: const Uuid().v4(),
      postId: post.id,
      fromUserId: fromUserId,
      toUserId: post.userId,
      message: message.trim(),
      createdAt: DateTime.now(),
    );
    return _contacts.put(contact.id, contact.toMap());
  }

  Future<void> setContactStatus(RoommateContact contact, String status) {
    contact.status = status;
    return _contacts.put(contact.id, contact.toMap());
  }
}
