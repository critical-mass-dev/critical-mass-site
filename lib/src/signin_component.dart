import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:firebase_dart_ui/firebase_dart_ui.dart';
import 'package:firebase/firebase.dart' as fb;

import 'package:firebase/src/interop/firebase_interop.dart';

import 'package:js/js.dart';

import 'dart:js';

import 'auth_service.dart';
import 'route_paths.dart';

@Component(
  selector: 'signin',
  template:
      '''<firebase-auth-ui [disableAutoSignIn]="false" [uiConfig]="getUIConfig()"></firebase-auth-ui>''',
  directives: [FirebaseAuthUIComponent],
)
class SigninComponent implements OnInit {
  UIConfig _uiConfig;
  Router _router;

  SigninComponent(this._router);

  @override
  void ngOnInit() {
    if (AuthService.currentUser() != null &&
        AuthService.verifiedEmail() == null) {
      _router.navigate(RoutePaths.verifyEmail.toUrl());
    }
  }

  UIConfig getUIConfig() {
    if (_uiConfig == null) {
      final googleOptions = CustomSignInOptions(
          provider: fb.GoogleAuthProvider.PROVIDER_ID,
          scopes: ['email'],
          customParameters: GoogleCustomParameters(prompt: 'select_account'));

      final emailOptions = CustomSignInOptions(
        provider: fb.EmailAuthProvider.PROVIDER_ID,
        scopes: ['email'],
        customParameters: EmailCustomParameters(requireDisplayName: false),
      );

      final facebookOptions = CustomSignInOptions(
        provider: fb.FacebookAuthProvider.PROVIDER_ID,
        scopes: ['email'],
      );

      _uiConfig = UIConfig(
          signInSuccessUrl: '',
          signInOptions: [
            googleOptions,
            facebookOptions,
            emailOptions,
          ],
          signInFlow: "popup",
          credentialHelper: NONE,
          tosUrl: '/tos.html');
    }
    return _uiConfig;
  }
}
