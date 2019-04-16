import 'package:angular_router/angular_router.dart';

import 'package:firebase/firebase.dart' as fb;
import 'package:rxdart/rxdart.dart';

import 'route_paths.dart';

class AuthService {
  // TODO: clean up interaction between these and the auth component.
  static final PublishSubject<bool> showSigninStream = PublishSubject<bool>();
  static final BehaviorSubject<fb.User> userStream = BehaviorSubject<fb.User>();
  static bool fbAuthInitialized = false;

  static fb.User currentUser() => fb.auth().currentUser;

  static Function onSigninSuccess;

  Router _router;

  AuthService(this._router);

  // TODO: is there a better solution?
  static void init() {
    fb.auth().onAuthStateChanged.listen((u) {
      fbAuthInitialized = true;
      // force signin callback
      if (u != null && onSigninSuccess != null) {
        onSigninSuccess();
      }
      userStream.add(u);
    });
  }

  static Future<fb.User> userAfterInit() async {
    if (fbAuthInitialized) {
      return currentUser();
    }
    return fb.auth().onAuthStateChanged.first;
  }

  Future<Null> logout() async {
    await fb.auth().signOut();
    _router.navigate('');
  }

  static bool signinSuccessHandler(
      fb.UserCredential credential, String redirectUrl) {
    return onSigninSuccess();
  }

  static String verifiedEmail() {
    final user = currentUser();
    if (user == null) {
      return null;
    }
    return user.emailVerified ? user.email : null;
  }

  void runSignin({String returnUrl}) {
    final preAuthUrl = returnUrl ?? (_router.current?.path ?? '/');
    onSigninSuccess = () {
      showSigninStream.add(false);
      if (verifiedEmail() != null) {
        _router.navigate(preAuthUrl);
        return false;
      }
      currentUser().sendEmailVerification(
          fb.ActionCodeSettings(url: 'https://criticalmass.works$preAuthUrl'));
      _router.navigate(RoutePaths.verifyEmail.toUrl());
      return false;
    };
    _router.navigate(RoutePaths.signin.toUrl());
    showSigninStream.add(true);
  }

  void forceLogin(String returnUrl) {
    assert(fbAuthInitialized);
    if (currentUser() == null) {
      runSignin(returnUrl: returnUrl);
    } else if (!currentUser().emailVerified) {
      _router.navigate(RoutePaths.verifyEmail.toUrl());
    }
  }
}

mixin ForceLogin implements OnActivate {
  AuthService authService;

  void onActivate(RouterState previous, RouterState current) {
    if (AuthService.fbAuthInitialized) {
      authService.forceLogin(current.toUrl());
    } else {
      fb.auth().onAuthStateChanged.take(1).listen((u) {
        authService.forceLogin(current.toUrl());
      });
    }
  }
}
