import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:firebase/firebase.dart' as fb;

import 'package:join/app_component.template.dart' as ng;

import 'main.template.dart' as self;

@GenerateInjector([
  routerProviders,
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  fb.initializeApp(
      apiKey: 'AIzaSyBA3BkCTKO6-GCWhsfmi6sBb1ibtFpU1KI',
      authDomain: 'criticalmass.works',
      databaseURL: "https://joint-45cb3.firebaseio.com",
      projectId: "joint-45cb3",
      storageBucket: "joint-45cb3.appspot.com",
      messagingSenderId: "820638465328");

  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
