import 'package:nmea/src/checksum_sentence.dart';
import 'package:nmea/src/nmea_sentence_type.dart';

class TalkerSentence extends ChecksumSentence {
  /// By default, returns the first two characters in the first field as per
  /// NMEA0183 standard.
  String get source => fields.isNotEmpty ? fields[0].substring(0, 2) : "";

  /// Returns all characters between the talker id and the end of the first
  /// field, excluding all characters from the source.
  String get mnemonic => fields.isNotEmpty ? fields[0].substring(2) : "";

  /// The [TalkerSentence] constructor has the same arguments as
  /// [ChecksumSentence], except that it specifies the type of this
  /// `NmeaSentence` as [NmeaSentenceType.talker].
  TalkerSentence({required super.raw, super.prefix})
      : super(type: NmeaSentenceType.talker);
}
