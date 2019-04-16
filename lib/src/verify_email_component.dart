import 'package:angular/angular.dart';

import 'auth_service.dart';

@Component(
  selector: 'verify-email',
  template:
      '''Please verify your {{AuthService.currentUser()?.email}} email to continue.''',
  exports: [AuthService],
)
class VerifyEmailComponent {}
