import 'package:flutter_extended_nmea/flutter_extended_nmea.dart';
import 'package:test/test.dart';

void main() {
  test("decodes talker sentences", () {
    final decoder = NmeaDecoder()
      ..registerTalkerSentence(TestTalkerSentence.id, (line) => TestTalkerSentence(raw: line));
    final decoded = decoder.decodeTalker("\$--TES,123,345*56");

    expect(decoded, isNotNull);
    expect(decoded!.source, equals("--"));
    expect(decoded.mnemonic, equals("TES"));
    expect(decoded.fields, equals(["--TES", "123", "345"]));
    expect(decoded.rawWithoutFixtures, "--TES,123,345");
    expect(decoded.hasChecksum, isTrue);
    expect(decoded.checksum, equals("56"));
    expect(decoded.actualChecksum, equals("40"));
    expect(decoded.valid, isFalse);
    expect(decoded.raw, equals("\$--TES,123,345*56"));
  });

  test("decodes query sentences", () {
    final decoder = NmeaDecoder();
    final decoded = decoder.decodeQuery("\$GPECQ,RMC");

    expect(decoded, isNotNull);
    expect(decoded!.valid, isTrue);
    expect(decoded.target, equals("GP"));
    expect(decoded.source, equals("EC"));
    expect(decoded.mnemonic, equals("RMC"));
  });

  test("converts invalid sentences to null", () {
    final decoder = NmeaDecoder();

    expect(decoder.decode("NOT NMEA"), isNull);
    expect(decoder.decode(""), isNull);
    expect(decoder.decode("\$P"), isNull);
  });
}

class TestTalkerSentence extends TalkerSentence {
  static const String id = "TES";

  TestTalkerSentence({required super.raw});
}
