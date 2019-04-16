import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'auth_service.dart';
import 'compact.dart';
import 'compact_service.dart';
import 'route_paths.dart';
import 'user.dart';
import 'user_service.dart';

@Component(
  selector: 'profile',
  template: '''
  <h1>Profile.</h1>
  <div *ngIf="AuthService.currentUser != null">
    Email: {{AuthService.verifiedEmail()}}
    <h2 mt-3>Pledged Compacts</h2>
    <div *ngFor="let c of pledged">
      <nav>
      <div class="card mt-3 mb-3">
        <div class="card-body">
          <a class="card-title"
            [routerLink]="compactPath(c.pledge.compactId)"
            [routerLinkActive]="'active'">{{c.compact.title}}
          </a>
        </div>
        <ul class="list-group list-group-flush">
          <li class="list-group-item"><b># Pledged:&nbsp;</b>{{c.compact.numPledged}}</li>
          <li class="list-group-item"><b># Activated:&nbsp;</b>{{c.compact.numActivated}}</li>
        </ul>
      </div>
      </nav>
    </div>
    <h2>Created Compacts</h2>
    <div *ngFor="let c of created">
    <nav>
    <div class="card mt-3 mb-3">
      <div class="card-body">
        <a class="card-title"
          [routerLink]="compactPath(c.id)"
          [routerLinkActive]="'active'">{{c.title}}
        </a>
      </div>
      <ul class="list-group list-group-flush">
        <li class="list-group-item"><b># Pledged:&nbsp;</b>{{c.numPledged}}</li>
        <li class="list-group-item"><b># Activated:&nbsp;</b>{{c.numActivated}}</li>
      </ul>
    </div>
    </nav>
    </div>
    <button class="btn btn-danger mt-3" (click)="authService.logout()">Logout</button>
  </div>
  ''',
  directives: [coreDirectives, routerDirectives],
  exports: [AuthService, RoutePaths],
)
class ProfileComponent with ForceLogin implements OnInit {
  List<_PledgedCompact> _pledged = [];
  get pledged => _pledged;
  List<CompactSummary> _created = [];
  get created => _created;
  AuthService _authService;
  get authService => _authService;
  UserService _userService;
  CompactService _compactService;

  ProfileComponent(this._authService, this._userService, this._compactService);

  @override
  void ngOnInit() {
    _userService.user.stream.listen((user) async {
      if (user == null) {
        return;
      }
      final ids = Set<String>();
      ids.addAll(user.createdCompactIds);
      ids.addAll(user.pledgedCompacts.map((pc) => pc.compactId));
      final summaries = Map<String, CompactSummary>();

      await Future.wait(ids.map((id) {
        return _fetchSummary(id, summaries);
      }), eagerError: true);
      _created.addAll(user.createdCompactIds.map((id) => summaries[id]));
      _pledged.addAll(user.pledgedCompacts
          .map((pc) => _PledgedCompact(pc, summaries[pc.compactId])));
    });
  }

  Future<void> _fetchSummary(
      String id, Map<String, CompactSummary> summaries) async {
    summaries[id] = await _compactService.getCompactSummary(id);
  }

  String compactPath(String id) {
    return RoutePaths.compact.toUrl(parameters: {idParam: id});
  }
}

class _PledgedCompact {
  Pledge pledge;
  CompactSummary compact;
  _PledgedCompact(this.pledge, this.compact);
}
