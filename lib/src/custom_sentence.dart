import 'package:nmea/nmea.dart';

/// An [NmeaSentence] where the data format is completely customizable, as
/// long as it fits in the general envelope of an NMEA0183 sentence (begins with
/// '$' and ends with windows-style newline characters).
class CustomSentence extends NmeaSentence {
  /// The [CustomChecksumSentence] constructor forwards all arguments to the
  /// [NmeaSentence] constructor, except the [type] parameter.
  /// The [type] is always [NmeaSentenceType.custom].
  CustomSentence({required this.identifier, required super.raw, super.prefix})
  : super(type: NmeaSentenceType.custom);

  /// Returns the identifier used to identify this sentence type
  final String identifier;
}
