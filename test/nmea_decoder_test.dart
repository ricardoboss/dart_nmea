import 'package:nmea/nmea.dart';
import 'package:test/test.dart';

void main() {
  test('decodes talker sentences', () {
    final decoder = NmeaDecoder()
      ..registerTalkerSentence(
        TestTalkerSentence.id,
        (line) => TestTalkerSentence(raw: line),
      );
    final decoded = decoder.decodeTalker(r'$--TES,123,345*56');

    expect(decoded, isNotNull);
    expect(decoded!.source, equals('--'));
    expect(decoded.mnemonic, equals('TES'));
    expect(decoded.fields, equals(['--TES', '123', '345']));
    expect(decoded.rawWithoutFixtures, '--TES,123,345');
    expect(decoded.hasChecksum, isTrue);
    expect(decoded.checksum, equals('56'));
    expect(decoded.actualChecksum, equals('40'));
    expect(decoded.valid, isFalse);
  });

  test('decodes custom sentences with invalid checksums', () {
    final decoder = NmeaDecoder()
      ..registerCustomChecksumSentence(
        TestCustomSentence.id,
        (line) => TestCustomSentence(raw: line),
      );
    final decoded = decoder.decodeCustomChecksum(r'$CST,123,345*56');

    expect(decoded, isNotNull);
    expect(decoded!.fields, equals(['CST', '123', '345']));
    expect(decoded.rawWithoutFixtures, 'CST,123,345');
    expect(decoded.hasChecksum, isTrue);
    expect(decoded.checksum, equals('56'));
    expect(decoded.actualChecksum, equals('46'));
    expect(decoded.valid, isFalse);
  });

  test('decodes custom sentences with valid checksums', () {
    final decoder = NmeaDecoder()
      ..registerCustomChecksumSentence(
        TestCustomSentence.id,
        (line) => TestCustomSentence(raw: line),
      );
    final decoded = decoder.decodeCustomChecksum(r'$CST,123,345*46');

    expect(decoded, isNotNull);
    expect(decoded!.fields, equals(['CST', '123', '345']));
    expect(decoded.rawWithoutFixtures, 'CST,123,345');
    expect(decoded.hasChecksum, isTrue);
    expect(decoded.checksum, equals('46'));
    expect(decoded.actualChecksum, equals('46'));
    expect(decoded.valid, isTrue);
  });

  test('decodes custom sentences with skipped checksums', () {
    final decoder = NmeaDecoder()
      ..registerCustomChecksumSentence(
        TestCustomSentence.id,
        (line) => TestCustomSentence(raw: line, validateChecksums: false),
      );
    final decoded = decoder.decodeCustomChecksum(r'$CST,123,345*56');

    expect(decoded, isNotNull);
    expect(decoded!.fields, equals(['CST', '123', '345']));
    expect(decoded.rawWithoutFixtures, 'CST,123,345');
    expect(decoded.hasChecksum, isTrue);
    expect(decoded.checksum, equals('56'));
    expect(decoded.actualChecksum, equals('46'));
    expect(decoded.valid, isTrue);
  });

  test('decodes invalid custom sentences although checksum checks are skipped',
      () {
    final decoder = NmeaDecoder()
      ..registerCustomChecksumSentence(
        TestCustomSentence.id,
        (line) => TestCustomSentence(raw: line, validateChecksums: false),
      );
    final decoded = decoder.decodeCustomChecksum(r'$CST,123345*56');

    expect(decoded, isNotNull);
    expect(decoded!.fields, equals(['CST', '123345']));
    expect(decoded.rawWithoutFixtures, 'CST,123345');
    expect(decoded.hasChecksum, isTrue);
    expect(decoded.checksum, equals('56'));
    expect(decoded.actualChecksum, equals('6A'));
    expect(decoded.valid, isFalse);
  });

  test('decodes query sentences', () {
    final decoder = NmeaDecoder();
    final decoded = decoder.decodeQuery(r'$GPECQ,RMC');

    expect(decoded, isNotNull);
    expect(decoded!.valid, isTrue);
    expect(decoded.target, equals('GP'));
    expect(decoded.source, equals('EC'));
    expect(decoded.mnemonic, equals('RMC'));
  });

  test('converts invalid sentences to null', () {
    final decoder = NmeaDecoder();

    expect(decoder.decode('NOT NMEA'), isNull);
    expect(decoder.decode(''), isNull);
    expect(decoder.decode(r'$P'), isNull);
  });
}

class TestTalkerSentence extends TalkerSentence {
  TestTalkerSentence({required super.raw});

  static const String id = 'TES';
}

class TestCustomSentence extends CustomChecksumSentence {
  TestCustomSentence({required super.raw, super.validateChecksums = true})
      : super(identifier: id);

  static const String id = 'CST';

  @override
  bool get valid => super.valid && fields.length == 3;
}
