class Timer {
  const Timer();

  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (i) => ticks - i - 1).take(ticks);
  }
}
