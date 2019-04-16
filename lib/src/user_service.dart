import 'dart:async';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;
import 'package:rxdart/rxdart.dart';

import 'auth_service.dart';
import 'callable_cloud_functions.dart';
import 'user.dart';

abstract class UserService {
  final BehaviorSubject<User> user = null;

  void pledge(Pledge pledge);
  void unpledge(String compactId);
}

class FirebaseUserService implements UserService {
  static const _usersCollectionKey = 'users';
  static const _pledgeFn = 'pledge';
  static const _unpledgeFn = 'unpledge';

  fs.Firestore _firestore;
  StreamSubscription _userSub;
  final user = BehaviorSubject<User>.seeded(null);

  FirebaseUserService() {
    _firestore = fb.firestore();

    AuthService.userStream.listen((u) {
      if (u == null) {
        user.add(null);
        _userSub?.cancel();
        return;
      }
      _userSub = _firestore
          .doc('$_usersCollectionKey/${u.uid}')
          .onSnapshot
          .listen((doc) {
        if (doc.data() == null) {
          return;
        }
        user.add(_userFromSnapshot(doc));
      });
    });
  }

  User _userFromSnapshot(fs.DocumentSnapshot doc) {
    final data = doc.data();
    final ret = User();
    final created = data['created'] ?? [];
    ret.createdCompactIds = List<String>.from(created);
    final pledged = data['pledged'] ?? {};
    pledged.forEach((k, v) => ret.pledgedCompacts.add(Pledge(k, v)));
    return ret;
  }

  Future<void> pledge(Pledge pledge) async {
    await callCloudFn(_pledgeFn, data: {
      'id': pledge.compactId,
      'threshold': pledge.pledgeThreshold,
    });
  }

  Future<void> unpledge(String compactId) async {
    await callCloudFn(_unpledgeFn, data: {
      'id': compactId,
    });
  }
}
