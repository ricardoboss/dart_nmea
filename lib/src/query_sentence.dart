import 'package:flutter_extended_nmea/flutter_extended_nmea.dart';

/// This character, at the correct position (index 5), classifies an NMEA0183
/// sentence as a query.
const nmeaQueryDenominator = 'Q';

/// An [NmeaSentence] that can be queried for its type.
class QuerySentence extends NmeaSentence {
  /// Returns the first two characters in the first field as per NMEA0183
  /// standard. This represents the queried party.
  String get target => idField.isNotEmpty ? idField.substring(0, 2) : "";

  /// Returns the third and fourth characters in the first field as per NMEA0183
  /// standard. This represents the querying party.
  String get source => idField.isNotEmpty ? idField.substring(2, 4) : "";

  /// The mnemonic being requested by the source from the target.
  String get mnemonic => fields.length > 1 ? fields[1] : "";

  /// The first field of the sentence. It contains the target and source ids and
  /// the denominator for query sentences ([nmeaQueryDenominator]).
  String get idField => fields.isNotEmpty ? fields[0] : "";

  bool? _valid;

  @override
  bool get valid => _valid ??=
      super.valid && idField.length == 5 && idField[4] == nmeaQueryDenominator;

  /// The [QuerySentence] constructor has the same arguments as [NmeaSentence],
  /// except that it specifies the type of this sentence as
  /// [NmeaSentenceType.query].
  QuerySentence({required super.raw, super.prefix})
      : super(type: NmeaSentenceType.query);
}
