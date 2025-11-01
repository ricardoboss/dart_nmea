import 'package:nmea/src/nmea_sentence.dart';
import 'package:nmea/src/nmea_sentence_type.dart';

/// This character, at the correct position (after '$'), classifies an NMEA0183
/// sentence as proprietary.
const nmeaProprietaryDenominator = 'P';

/// The full prefix of a valid NMEA0183 proprietary sentence ('$P').
const nmeaProprietaryPrefix = nmeaPrefix + nmeaProprietaryDenominator;

/// Proprietary NMEA0183 sentences are defined by manufacturers of NMEA sources
/// and don't have to structure their data like other NMEA sentences. The data
/// format is completely customizable, as long as it fits in the general
/// envelope of an NMEA0183 sentence (begins with '$' and ends with windows-
/// style newline characters).
class ProprietarySentence extends NmeaSentence {
  /// The manufacturer and the raw input line are needed to decide if this
  /// sentence is valid. The manufacturer is needed to check the prefix in case
  /// the manufacturer doesn't use the default field separator (',') to separate
  /// the fields.
  ProprietarySentence({required this.manufacturer, required super.raw})
      : super(
          type: NmeaSentenceType.proprietary,
          prefix: nmeaProprietaryPrefix + manufacturer,
        );

  /// Returns the manufacturer id (i.e. the first field in the sentence,
  /// excluding the proprietary denominator [nmeaProprietaryDenominator]).
  final String manufacturer;
}
