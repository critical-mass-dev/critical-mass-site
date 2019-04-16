import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'auth_service.dart';
import 'compact_service.dart';
import 'route_paths.dart';
import 'user_service.dart';

@Component(
  selector: 'create-compact',
  template: '''
  <div class="container">
  <h1>New Compact</h1>
  <form (ngSubmit)="onSubmit()" #compactForm="ngForm">
    <div class="form-group">
      <label for="name">Title</label>
      <input type="text" class="form-control" maxlen="500" placeholder="Like 'Quit Facebook' or 'Go Bungee Jumping'" id="name" required
      [(ngModel)]="model.title"
        ngControl="title"
      >
    </div>
    <div class="form-group">
      <label for="description">Description</label>
      <textarea class="form-control" rows="10" id="description"  maxlen="10000" placeholder="What you and others are pledging to do together." required
      [(ngModel)]="model.description"
        ngControl="description"></textarea>
    </div>
    <div class="form-group">
      <label for="call">Call to Action</label>
      <small id="callHelp" class="form-text text-muted">Optional</small>
      <textarea class="form-control" rows="10" id="call"  maxlen="10000" placeholder="An optional message to people who hit their thresholds to take action."
      [(ngModel)]="model.callToAction"
        ngControl="call"></textarea>
    </div>
    <div class="form-group form-check">
      <input type="checkbox" class="form-check-input" id="discoverable"
      [(ngModel)]="model.discoverable"
        ngControl="discoverable">
        <label class="form-check-label" for="disoverable">Make this discoverable?</label>
        <small id="discoverableHelp" class="form-text text-muted">If this is unchecked, only people with the link can see this compact.</small>
    </div>
    <div class="form-group form-check">
      <input type="checkbox" class="form-check-input" id="showEmail"
      [(ngModel)]="model.showEmail"
        ngControl="showEmail">
      <label class="form-check-email" for="showEmail">Show my email on the compact page?</label>
    </div>
      <button [disabled]="!compactForm.valid || submitted" type="submit" class="btn btn-primary">
        <span class="spinner-border spinner-border-sm" role="status" *ngIf="submitted"></span>
        {{submitted ? 'Submitting...' : 'Submit'}}
      </button>
  </form>
  </div>
  ''',
  directives: [coreDirectives, formDirectives],
)
//TODO: give visual feedback on invalid (e.g. too large, missing) form field entries.
class CreateCompactComponent with ForceLogin {
  CompactService _compactService;
  Router _router;
  UserService _userService;
  CompactCreationRequest model = CompactCreationRequest();
  bool submitted = false;

  CreateCompactComponent(
      AuthService auth, this._compactService, this._router, this._userService) {
    super.authService = auth;
  }

  void onSubmit() async {
    if (submitted) {
      return;
    }
    submitted = true;
    // for a newly created user, wait until the user FB initialization has finished.
    await _userService.user.firstWhere((u) => u != null);
    final id = await _compactService.createCompact(model);
    _router.navigate(RoutePaths.compact.toUrl(parameters: {idParam: id}));
  }
}
