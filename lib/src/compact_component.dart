import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'auth_service.dart';
import 'compact.dart';
import 'compact_service.dart';
import 'route_paths.dart';
import 'user.dart';
import 'user_service.dart';

// TODO: add/format all the fields, indicate if the pledge is activated
@Component(
  selector: 'compact',
  template: '''
  <div style="width:90%; margin:auto;" *ngIf="compact != null">
  <h2>{{compact.summary.title}}</h2>
  <div *ngIf="compact.summary.creatorEmail != null">
    Created by: <a href="mailto:{{compact.summary.creatorEmail}}">{{compact.summary.creatorEmail}}</a>
  </div>
  {{compact.summary.numActivated + compact.summary.numUnactivated}} people signed on,
  {{compact.summary.numActivated}} people active.
  <br><br>{{compact.description}}
  <hr>
  <div *ngIf="pledge == null">
  <form (ngSubmit)="onPledge()" #compactForm="ngForm">
    <div class="form-group">
      <label for="pledgeThreshold">Pledge threshold</label>
      <input type="number" class="form-control" id="pledgeThreshold" placeholder="If this many other people do it, you'll do it too." required
      [(ngModel)]="pledgeThreshold"
        ngControl="pledgeThreshold"
      >
    </div>
      <button [disabled]="!compactForm.valid || !pledgeButtonActive" type="submit" class="btn btn-primary">
        <span class="spinner-border spinner-border-sm" role="status" *ngIf="!pledgeButtonActive"></span>
        {{pledgeButtonActive ? 'Pledge' : 'Pledging...'}}
      </button>
  </form>
  </div>
  <div *ngIf="pledge != null">
    You pledged to do this if {{pledge.pledgeThreshold}} other people do.<br>
    <button [disabled]="pledgeButtonActive || (pledge != null && pledge.pledgeThreshold <= compact.summary.numActivated)" (click)="onUnpledge()" class="btn btn-primary">
      <span class="spinner-border spinner-border-sm" role="status" *ngIf="pledgeButtonActive"></span>
      {{pledgeButtonActive ? 'Unpledging...' : 'Unpledge'}}
    </button>
    <small *ngIf="(pledge != null && pledge.pledgeThreshold <= compact.summary.numActivated)" id="unpledgeHelp" class="form-text text-danger">You cannot unpledge after you've been activated.</small>
  </div>
  </div>
  ''',
  directives: [coreDirectives, formDirectives],
)
class CompactComponent implements OnActivate {
  AuthService _authService;
  CompactService _compactService;
  UserService _userService;
  int pledgeThreshold;
  Compact _compact;
  Pledge _pledge;
  get compact => _compact;
  get pledge => _pledge;
  get userService => _userService;
  bool pledgeButtonActive;

  CompactComponent(this._authService, this._compactService, this._userService);

  @override
  void onActivate(_, RouterState current) async {
    final id = current.parameters[idParam];
    // TODO: listen to compact.
    _compactService.compactStream(id).listen((c) => _compact = c);
    _userService.user.listen((u) {
      if (u == null) {
        _pledge = null;
        return;
      }
      for (final pc in u.pledgedCompacts) {
        if (pc.compactId == _compact?.summary?.id) {
          _pledge = pc;
          pledgeButtonActive = false;
          return;
        }
      }
      pledgeButtonActive = true;
      _pledge = null;
    });
  }

  void onUnpledge() async {
    if (pledgeButtonActive) {
      return;
    }
    pledgeButtonActive = true;
    await userService.unpledge(compact.summary.id);
  }

  void onPledge() async {
    if (!pledgeButtonActive) {
      return;
    }
    pledgeButtonActive = false;
    await userService.pledge(Pledge(compact.summary.id, pledgeThreshold));
  }
}
