import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'src/about_component.dart';
import 'src/auth_service.dart';
import 'src/compact_service.dart';
import 'src/footer_component.dart';
import 'src/header_component.dart';
import 'src/signin_component.dart';
import 'src/routes.dart';
import 'src/user_service.dart';

@Component(
  selector: 'my-app',
  template: '''
  <div class="container-fluid">
  <header></header>
  <body>
  <div class="container">
    <signin [hidden]="!showSignin"></signin>
    <nav>
    </nav>
    <router-outlet [routes]="Routes.all"></router-outlet>
  </div>
  </body>
  </div>
  <footercomp></footercomp>
''',
  directives: [
    routerDirectives,
    FooterComponent,
    HeaderComponent,
    SigninComponent
  ],
  providers: [
    ClassProvider(AboutComponent),
    ClassProvider(AuthService),
    ClassProvider(FooterComponent),
    ClassProvider(HeaderComponent),
    ClassProvider(SigninComponent),
    ClassProvider(CompactService, useClass: FirebaseCompactService),
    ClassProvider(UserService, useClass: FirebaseUserService),
  ],
  styleUrls: ['app_component.css'],
  exports: [RoutePaths, Routes],
)
class AppComponent implements OnInit {
  bool _showSignin = false;
  get showSignin => _showSignin;

  @override
  void ngOnInit() {
    AuthService.init();
    AuthService.showSigninStream.stream.listen((show) {
      _showSignin = show;
    });
  }
}
