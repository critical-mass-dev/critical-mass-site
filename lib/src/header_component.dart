import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'auth_service.dart';
import 'routes.dart';

@Component(
  selector: 'header',
  template: '''
<nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top d-flex justify-content-between">
  <a class="navbar-brand" href="/">Critical Mass</a>
  <button type="button"
    class="btn btn-primary"
    *ngIf="AuthService.fbAuthInitialized && AuthService.verifiedEmail() == null"
    (click)="authService.runSignin()"
    >Sign in
  </button>
  <div *ngIf="AuthService.verifiedEmail() != null">
  <i
    class="material-icons"
    style="cursor: pointer;"
    [routerLink]="RoutePaths.create.toUrl()"
    [routerLinkActive]="'active'">note_add
  </i>
  <i
    class="material-icons"
    style="cursor: pointer;"
    [routerLink]="RoutePaths.profile.toUrl()"
    [routerLinkActive]="'active'">person
  </i>
  </div>
</nav>
''',
  directives: [coreDirectives, routerDirectives],
  exports: [RoutePaths, AuthService],
  providers: [ClassProvider(AuthService)],
)
class HeaderComponent {
  AuthService _authService;

  HeaderComponent(this._authService);

  get authService => _authService;
}
