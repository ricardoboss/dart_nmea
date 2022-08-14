import 'package:nmea/src/checksum_sentence.dart';
import 'package:nmea/src/nmea_sentence.dart';
import 'package:nmea/src/nmea_sentence_type.dart';

/// The data format is completely customizable, as long as it fits in the general
/// envelope of an NMEA0183 sentence (begins with '$' and ends with windows-
/// style newline characters).
class CustomSentence extends ChecksumSentence {
  /// Returns the identifier used to identify this sentence type
  final String identifier;
  final bool validateChecksums;

  CustomSentence(
      {required this.identifier,
      required super.raw,
      this.validateChecksums = true})
      : super(
          type: NmeaSentenceType.unknown,
          prefix: nmeaPrefix,
        );

  @override
  bool get valid => super.valid || !validateChecksums;
}
