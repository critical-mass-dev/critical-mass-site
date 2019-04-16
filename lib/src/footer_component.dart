import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(
  selector: 'footercomp',
  template: '''
  <div class="bg-light container-fluid min-vw-100 ml-0 mr-0 mb-n1 mt-1 position-sticky">
    <p><small><a href="mailto:contact@criticalmass.works">Contact Us</a></small></p>
    <p><small><nav><a [routerLink]="RoutePaths.about.toUrl()"
        [routerLinkActive]="'active'">About</a></nav></small></p>
    <p><small><nav><a [routerLink]="RoutePaths.privacy.toUrl()"
        [routerLinkActive]="'active'">Privacy Policy</a></nav></small></p>

  </div>
  ''',
  directives: [routerDirectives],
  exports: [RoutePaths],
)
class FooterComponent {}
