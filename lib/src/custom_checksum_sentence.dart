import 'package:nmea/src/checksum_sentence.dart';
import 'package:nmea/src/nmea_sentence_type.dart';

/// A [ChecksumSentence] where the data format is completely customizable, as
/// long as it fits in the general envelope of an NMEA0183 sentence (begins with
/// '$' and ends with windows-style newline characters) and has a checksum.
class CustomChecksumSentence extends ChecksumSentence {
  /// Returns the identifier used to identify this sentence type
  final String identifier;

  /// Decides whether or not to validate the checksum on this sentence
  final bool validateChecksums;

  /// The [CustomChecksumSentence] constructor forwards all arguments to the
  /// [ChecksumSentence] constructor, except the [type] parameter.
  /// The [type] is always [NmeaSentenceType.custom].
  CustomChecksumSentence(
      {required this.identifier,
      required super.raw,
      super.prefix,
      this.validateChecksums = true})
      : super(type: NmeaSentenceType.custom);

  @override
  bool get hasValidChecksum => super.hasValidChecksum || !validateChecksums;
}
