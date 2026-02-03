class Timestamp {
  final int seconds;
  final int nanos;
  const Timestamp({this.seconds = 0, this.nanos = 0});

  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanos ~/ 1000000));

  static Timestamp fromDateTime(DateTime dt) =>
      Timestamp(seconds: dt.millisecondsSinceEpoch ~/ 1000, nanos: (dt.millisecondsSinceEpoch % 1000) * 1000000);
}
