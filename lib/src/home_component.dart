import 'package:angular/angular.dart';

@Component(
  selector: 'home',
  template: '''
  <p>Is there something you want to do, but only if you're not doing it alone?
  Critical Mass is a site to help solve that problem. It lets you create
  compacts-- agreements that anyone can sign onto where they agree to do
  something if enough other people sign on.</p>
  <br>
  <ol>
  <li>Create a new compact.</li>
  <li>Spread the compact page around.</li>
  <li>As more people sign on, more people get activated.</li>
  <li>Now you have a bunch of people doing the thing alongside you.</li>
  </ol>
  <br>
  Critical Mass works for little things ("I'll go skydiving if 3 of my friends
  do") and it works for big things ("I'll quit Facebook if 30 of my friends do")
  . Have fun!
  ''',
)
class HomeComponent {}
