import 'package:angular/angular.dart';

@Component(
  selector: 'about',
  template: '''
  <div>
    <p>Critical Mass is a tool for helping people come together to do stuff they
    wouldn't do alone. It's a labor of love born from a desire to solve
    coordination problems with technology.</p>
    <p>We do not make a profit, and never will. We will never advertise to you
    or sell your information.</p>
    <p>If you have questions, ideas, or suggestions, please
    <a href="mailto:contact@criticalmass.works">contact us</a>.</p>
    <br><br>
    <small>Credit for Thumbs-Up icon to <a href="http://delapouite.com/">Delapouite</a>
    under <a href="http://creativecommons.org/licenses/by/3.0/">CC BY 3.0</a>.</small>
  </div>
  ''',
)
class AboutComponent {}
