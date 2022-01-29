import 'package:bloc/bloc.dart';
import 'package:counter/counter_observer.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(const CounterApp()),
    blocObserver: CounterBlocObserver(),
  );
}
