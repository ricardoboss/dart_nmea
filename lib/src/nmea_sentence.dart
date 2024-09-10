import 'package:nmea/src/nmea_sentence_type.dart';
import 'package:nmea/src/proprietary_sentence.dart';

/// Each NMEA0183 sentence starts with a "$" character.
const nmeaPrefix = r'$';

/// Each NMEA0183 sentence ends with windows-style newline characters.
const nmeaSuffix = '\r\n';

/// NMEA0183 fields are separated by one single comma.
const nmeaFieldSeparator = ',';

/// This is the base class for all NMEA0183 sentences.
///
/// You can extend it and build your own sentences if they have a different
/// structure than standard NMEA0183 sentences. If you are implementing a
/// proprietary sentence, you can use the [ProprietarySentence] class.
class NmeaSentence {
  /// Creates a new NmeaSentence.
  ///
  /// The [type] and the [raw] string source must be supplied. A [prefix] is
  /// optional and the default is the [nmeaPrefix] ("$").
  NmeaSentence({
    required this.type,
    required this.raw,
    this.prefix = nmeaPrefix,
  });

  /// The type of this sentence.
  final NmeaSentenceType type;

  /// The string source of this sentence.
  ///
  /// From this field, all other data is derived. The value is only guaranteed
  /// to contain a valid NMEA0183 sentence if the [valid] property is true.
  final String raw;

  /// The prefix used for this sentence.
  ///
  /// For normal NMEA sentences, this value will be [nmeaPrefix] ("$").
  /// Proprietary sentences will have a different prefix, depending on the
  /// manufacturer. By default, they will always start with
  /// [nmeaProprietaryPrefix] ("$P") followed by the manufacturer's three-letter
  /// code.
  final String prefix;

  List<String>? _fields;

  /// This property contains a list of fields found in the sentence. Fields
  /// are strings separated by commas, which sit between (i.e. excluding) the
  /// prefix ("$") and the suffix (for sentences with checksums, the checksum
  /// and checksum separator ("*") belong to the suffix).
  List<String> get fields =>
      _fields ??= rawWithoutFixtures.split(nmeaFieldSeparator);

  bool? _valid;

  /// Whether or not this sentence is a valid NMEA0183 sentence.
  ///
  /// All data is transmitted in the form of sentences. Only printable ASCII
  /// characters are allowed, plus CR (carriage return) and LF (line feed). Each
  /// sentence starts with a "$" sign and ends with "\r\n". For convenience,
  /// the line ending is not validated.
  ///
  /// It is not guaranteed that this will also validate the checksum as this
  /// depends on the sentence type being implemented.
  bool get valid => _valid ??= raw.startsWith(prefix);

  String? _rawWithoutFixtures;

  /// Returns the raw string source without [prefix] ("$" or "$P" + manufacturer
  /// id for proprietary sentences).
  String get rawWithoutFixtures =>
      _rawWithoutFixtures ??= raw.substring(prefix.length, raw.length);

  // MAYBE: add invalid reason field/getter
}
