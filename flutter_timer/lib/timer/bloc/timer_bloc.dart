import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer/timer.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Timer _timer;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Timer timer})
      : _timer = timer,
        super(const TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);

    on<TimerTicked>(_onTicked);

    on<TimerPaused>(_onPaused);

    on<TimerResumed>(_onResumed);

    on<TimerReset>(_onReset);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  // helper function

  FutureOr<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();

    _tickerSubscription = _timer.tick(ticks: event.duration).listen((duration) => add(TimerTicked(duration: duration)));
  }

  FutureOr<void> _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0 ? TimerRunInProgress(event.duration) : const TimerRunComplete(),
    );
  }

  FutureOr<void> _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();

      emit(TimerRunPause(state.duration));
    }
  }

  FutureOr<void> _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  FutureOr<void> _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();

    emit(const TimerInitial(_duration));
  }
}
