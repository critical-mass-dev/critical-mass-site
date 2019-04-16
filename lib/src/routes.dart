import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';
import 'about_component.template.dart' as about_template;
import 'compact_component.template.dart' as compact_template;
import 'create_compact_component.template.dart' as create_template;
import 'home_component.template.dart' as home_template;
import 'privacy_component.template.dart' as privacy_template;
import 'profile_component.template.dart' as profile_template;
import 'signin_component.template.dart' as signin_template;
import 'verify_email_component.template.dart' as verify_email_template;

export 'route_paths.dart';

class Routes {
  static final privacy = RouteDefinition(
    routePath: RoutePaths.privacy,
    component: privacy_template.PrivacyComponentNgFactory,
  );
  static final about = RouteDefinition(
    routePath: RoutePaths.about,
    component: about_template.AboutComponentNgFactory,
  );
  static final signin = RouteDefinition(
    routePath: RoutePaths.signin,
    component: signin_template.SigninComponentNgFactory,
  );
  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_template.HomeComponentNgFactory,
    useAsDefault: true,
  );
  static final profile = RouteDefinition(
    routePath: RoutePaths.profile,
    component: profile_template.ProfileComponentNgFactory,
  );
  static final create = RouteDefinition(
    routePath: RoutePaths.create,
    component: create_template.CreateCompactComponentNgFactory,
  );
  static final compact = RouteDefinition(
    routePath: RoutePaths.compact,
    component: compact_template.CompactComponentNgFactory,
  );
  static final verifyEmail = RouteDefinition(
    routePath: RoutePaths.verifyEmail,
    component: verify_email_template.VerifyEmailComponentNgFactory,
  );
  static final all = <RouteDefinition>[
    about,
    signin,
    home,
    profile,
    privacy,
    create,
    compact,
    verifyEmail
  ];
}
