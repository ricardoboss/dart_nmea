import 'package:nmea/nmea.dart';

/// The NMEA sentence checksum is between this character the new line
/// characters. The general format looks like this:
/// ```
/// $[talker][mnemonic],[field],[field]*[checksum]\r\n
/// ```
const nmeaChecksumSeparator = '*';

/// This class represents NMEA0183 sentences with a checksum. This applies to
/// [TalkerSentence]s and [QuerySentence]s. [ProprietarySentence]s on the other
/// hand are not required to contain a checksum.
class ChecksumSentence extends NmeaSentence {
  bool? _valid;

  /// Whether or not this sentence is a valid NMEA0183 sentence, including a
  /// checksum check.
  ///
  /// This getter checks if the raw string source conforms to the general
  /// NMEA0183 requirements (starts with a "$" character) and also if the
  /// checksum is valid.
  @override
  bool get valid => _valid ??= super.valid && hasValidChecksum;

  bool? _hasChecksum;

  /// Whether or not this sentence contains the checksum separator.
  bool get hasChecksum => _hasChecksum ??= raw.contains(nmeaChecksumSeparator);

  String? _checksum;

  /// Reads the checksum contained in the raw string source. If the sentence
  /// does not contain a checksum, an empty string is returned.
  String get checksum => hasChecksum
      ? _checksum ??= raw.split(nmeaChecksumSeparator).last
      : ""; // MAYBE: uppercase the checksum even if it was not uppercase

  String? _actualChecksum;

  /// In contrast to the [checksum] property, this function calculates the
  /// actual checksum of the sentence, regardless of what checksum was
  /// originally sent along with it.
  /// The data used is provided by the [rawWithoutFixtures] property.
  String get actualChecksum =>
      _actualChecksum ??= NmeaUtils.xorChecksum(rawWithoutFixtures);

  /// Whether or not the actual checksum of the sentence matches the checksum
  /// contained in the raw string source.
  bool get hasValidChecksum => hasChecksum && checksum == actualChecksum;

  String? _rawWithoutFixtures;

  /// Returns the raw string source without [nmeaPrefix] ("$") and without
  /// checksum.
  ///
  /// This is the actual sentence, without any fixtures, which is used to
  /// calculate the checksum.
  @override
  String get rawWithoutFixtures =>
      _rawWithoutFixtures ??= super.rawWithoutFixtures.substring(
          0,
          super.raw.length -
              4); // -4 to remove the checksum + separator character

  /// The [ChecksumSentence] constructor has the same parameters as the parent
  /// [NmeaSentence] does.
  ChecksumSentence({
    required super.type,
    required super.raw,
    super.prefix,
  });
}
