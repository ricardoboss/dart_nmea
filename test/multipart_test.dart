import 'package:nmea/nmea.dart';
import 'package:test/test.dart';

void main() {
  test("decodes multipart messages in streams", () async {
    final decoder = NmeaDecoder()
      ..registerTalkerSentence(MultipartTestTalkerSentence.id,
          (line) => MultipartTestTalkerSentence(raw: line));

    final stream = Stream.fromIterable([
      "\$--TE1,1,3,123,456*78",
      "\$--TE1,2,3,789,012*34",
      "\$--TE1,3,3,345,678*56",
    ]);

    final decoded = await stream.transform(decoder).toList();

    expect(decoded.length, equals(1));
    expect(decoded[0], isA<MultipartTestTalkerSentence>());
    final multipart = decoded[0] as MultipartTestTalkerSentence;
    expect(multipart.total, equals(3));
    expect(multipart.sequence, equals(1));
    expect(multipart.values, equals([123, 456, 789, 012, 345, 678]));
    expect(multipart.complete, isTrue);
  });

  test("returns incomplete sentences at end-of-stream", () async {
    final decoder = NmeaDecoder()
      ..registerTalkerSentence(MultipartTestTalkerSentence.id,
          (line) => MultipartTestTalkerSentence(raw: line));

    final stream = Stream.fromIterable([
      "\$--TE1,1,3,123,456*78",
      "\$--TE1,2,3,789,012*34",
    ]);

    final decoded = await stream.transform(decoder).toList();

    expect(decoded.length, equals(1));
    expect(decoded[0], isA<MultipartTestTalkerSentence>());
    final multipart = decoded[0] as MultipartTestTalkerSentence;
    expect(multipart.total, equals(3));
    expect(multipart.sequence, equals(1));
    expect(multipart.values, equals([123, 456, 789, 012]));
    expect(multipart.complete, isFalse);
  });

  test("multipart sentences aren't affected by sentences received around them",
      () async {
    final decoder = NmeaDecoder()
      ..registerTalkerSentence(
          TestTalkerSentence.id, (line) => TestTalkerSentence(raw: line))
      ..registerTalkerSentence(MultipartTestTalkerSentence.id,
          (line) => MultipartTestTalkerSentence(raw: line));

    final stream = Stream.fromIterable([
      "\$--TE2,13415*34",
      "\$--TE1,1,3,123,456*78",
      "\$--TE2,123345*34",
      "\$--TE1,2,3,345,678*56",
      "\$--TE2,134123345*34",
      "\$--TE1,3,3,901,234*78",
      "\$--TE2,133345*34",
    ]);

    final decoded = await stream.transform(decoder).toList();

    expect(decoded.length, equals(5));
    expect(decoded[3], isA<MultipartTestTalkerSentence>());
    final multipart = decoded[3] as MultipartTestTalkerSentence;
    expect(multipart.total, equals(3));
    expect(multipart.sequence, equals(1));
    expect(multipart.values, equals([123, 456, 345, 678, 901, 234]));
    expect(multipart.complete, isTrue);
  });
}

class MultipartTestTalkerSentence
    extends MultipartSentence<MultipartTestTalkerSentence> {
  static const String id = "TE1";

  late List<int> _values;
  bool _isComplete = false;

  MultipartTestTalkerSentence({required super.raw}) {
    _values = fields.getRange(3, 5).map((e) => int.parse(e)).toList();
  }

  @override
  void appendFrom(MultipartTestTalkerSentence other) {
    _values.addAll(other._values);
    _isComplete = other.isLast;
  }

  @override
  int get sequence => int.parse(fields[1]);

  @override
  int get total => int.parse(fields[2]);

  bool get complete => _isComplete;

  List<int> get values => _values;
}

class TestTalkerSentence extends TalkerSentence {
  static const String id = "TE2";

  TestTalkerSentence({required super.raw});
}
