import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;
import 'package:rxdart/rxdart.dart';

import 'callable_cloud_functions.dart';
import 'compact.dart';

abstract class CompactService {
  Future<CompactSummary> getCompactSummary(String id);

  Future<Compact> getCompact(String id);

  BehaviorSubject<Compact> compactStream(String id);

  /// createCompact finalizes a compact request and issues it, returning the id
  /// of the created compact, or null on failure.
  Future<String> createCompact(CompactCreationRequest req);
}

class FirebaseCompactService implements CompactService {
  static const _compactsKey = 'compacts';
  static const _longFieldsKey = 'long_fields';
  static const _piecesKey = 'pieces';
  static const _createCompactFn = 'createCompact';

  fs.Firestore _firestore;

  FirebaseCompactService() {
    _firestore = fb.firestore();
  }

  BehaviorSubject<Compact> compactStream(String id) {
    final stream = BehaviorSubject<Compact>();
    _firestore.doc('$_compactsKey/$id').onSnapshot.listen((_) {
      getCompact(id).then((c) => stream.add(c));
    });
    return stream;
  }

  Future<Compact> getCompact(String id) async {
    final summary = getCompactSummary(id);
    final longDocRef =
        _firestore.doc('$_compactsKey/$id/$_piecesKey/$_longFieldsKey');
    final longDoc = await longDocRef.get();
    return Compact(await summary, longDoc.data()['description']);
  }

  Future<CompactSummary> getCompactSummary(String id) async {
    final compactSummaryRef = _firestore.doc('$_compactsKey/$id');
    final doc = await compactSummaryRef.get();
    final data = doc.data();
    return CompactSummary(data['title'], data['creatorEmail'],
        data['creationTs'], data['numActivated'], data['numUnactivated'], id);
  }

  Future<String> createCompact(CompactCreationRequest req) async {
    final res = await callCloudFn(_createCompactFn, data: {
      'title': req.title,
      'description': req.description,
      'callToAction': req.callToAction,
      'discoverable': req.discoverable,
      'showEmail': req.showEmail,
    });
    return res['result']['id'];
  }
}

// TODO: auto generate json encoding
class CompactCreationRequest {
  String title = '';
  String description = '';
  String callToAction = '';
  bool discoverable = false;
  bool showEmail = false;
}
