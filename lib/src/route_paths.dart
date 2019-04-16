import 'package:angular_router/angular_router.dart';

const idParam = 'id';

class RoutePaths {
  static final about = RoutePath(path: 'about');
  static final create = RoutePath(path: 'create');
  static final home = RoutePath(path: '');
  static final signin = RoutePath(path: 'signin');
  static final privacy = RoutePath(path: 'privacy');
  static final profile = RoutePath(path: 'profile');
  static final compact = RoutePath(path: 'compact/:$idParam');
  static final verifyEmail = RoutePath(path: 'verifyEmail');
}
