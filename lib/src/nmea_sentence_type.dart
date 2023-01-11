import 'package:nmea/nmea.dart';

/// The type of NMEA0183 sentence.
///
/// This can be used to check the type of sentence via a common interface
/// ([NmeaSentence]).
enum NmeaSentenceType {
  /// This sentence type is not known and can be used for custom
  /// implementations of [NmeaSentence].
  unknown,

  /// This sentence is a talker sentence containing data (see [TalkerSentence]).
  talker,

  /// This sentence is a query sentence which is sent by a source to a talker
  /// (see [QuerySentence]).
  query,

  /// This sentence is a proprietary sentence, whose format or function is not
  /// further specified (see [ProprietarySentence]).
  proprietary,

  /// This sentence is a completely custom sentence which might contain
  /// unexpected data (see [CustomSentence] and [CustomChecksumSentence]).
  custom,
}
