import 'dart:async';
import 'dart:convert';

import 'package:flutter_extended_nmea/src/multipart_sentence.dart';
import 'package:flutter_extended_nmea/src/nmea_sentence.dart';
import 'package:flutter_extended_nmea/src/proprietary_sentence.dart';
import 'package:flutter_extended_nmea/src/query_sentence.dart';
import 'package:flutter_extended_nmea/src/talker_sentence.dart';

/// A function to create a [ProprietarySentence] from a raw string and a
/// manufacturer id.
typedef ProprietarySentenceFactory = ProprietarySentence Function(String line);

/// A function to create a [TalkerSentence] from a raw string.
typedef TalkerSentenceFactory = TalkerSentence Function(String line);

/// A fallback function to create a [ProprietarySentence] from a raw string.
/// May return [null] if no conversion is available.
typedef OptionalProprietarySentenceFactory = ProprietarySentence? Function(
    String line);

/// A fallback function to create a [TalkerSentence] from a raw string. May
/// return [null] if no conversion is available.
typedef OptionalTalkerSentenceFactory = TalkerSentence? Function(String line);

/// A fallback function to create a [NmeaSentence] from a raw string. May
/// return [null] if no conversion is available.
typedef OptionalNmeaSentenceFactory = NmeaSentence? Function(String line);

/// A [StreamTransformer] that splits [String] lines into NMEA0183 sentence
/// objects ([NmeaSentence]).
///
/// This transformer would typically be used after a [LineSplitter], because
/// this transformer doesn't buffer the input and tries to parse every piece of
/// data it receives as a complete NMEA sentence.
class NmeaDecoder extends StreamTransformerBase<String, NmeaSentence> {
  final Map<String, ProprietarySentenceFactory> _proprietaryGenerators = {};
  final Map<String, TalkerSentenceFactory> _talkerGenerators = {};
  final List<MultipartSentence<dynamic>> _incompleteSentences = [];

  /// This method is invoked whenever a sentence is being decoded and it is
  /// already established that the sentence is a proprietary sentence, but no
  /// registered manufacturer id matches it.
  final OptionalProprietarySentenceFactory? onUnknownProprietarySentence;

  /// This method is invoked whenever a sentence is being decoded and it is
  /// already established that the sentence is a talker sentence, but no
  /// registered mnemonic matches it.
  final OptionalTalkerSentenceFactory? onUnknownTalkerSentence;

  /// This method is a fallback to create an [NmeaSentence] from a raw string
  /// if no other handler was able to decode the string.
  final OptionalNmeaSentenceFactory? onUnknownSentence;

  /// Whether or not this decoder only streams valid NMEA0183 sentences.
  /// Invalid sentences are silently ignored.
  final bool onlyAllowValid;

  /// Creates a new [NmeaDecoder] that only streams NMEA0183 sentences.
  /// You can pass functions to handle unknown sentences for different types.
  /// As a general callback, [onUnknownSentence] can be used.
  /// If you only want this stream transformer to pass on valid NMEA0183
  /// sentences, set [onlyAllowValid] to true.
  NmeaDecoder({
    this.onUnknownProprietarySentence,
    this.onUnknownTalkerSentence,
    this.onUnknownSentence,
    this.onlyAllowValid = false,
  });

  /// Registers a [ProprietarySentenceFactory] for a given manufacturer id.
  void registerProprietarySentence(
    String manufacturer,
    ProprietarySentenceFactory factory,
  ) {
    _proprietaryGenerators[manufacturer] = factory;
  }

  /// Registers a [TalkerSentenceFactory] for a given mnemonic.
  void registerTalkerSentence(
    String mnemonic,
    TalkerSentenceFactory factory,
  ) {
    _talkerGenerators[mnemonic] = factory;
  }

  @override
  Stream<NmeaSentence> bind(Stream<String> stream) async* {
    await for (var line in stream) {
      var sentence = decode(line);
      sentence ??= onUnknownSentence?.call(line);

      if (sentence == null || (onlyAllowValid && !sentence.valid)) {
        continue;
      }

      if (sentence is MultipartSentence) {
        final MultipartSentence<dynamic> part = sentence; // capture variable
        final existingIndex =
            _incompleteSentences.indexWhere((s) => s.mnemonic == part.mnemonic);
        if (existingIndex < 0) {
          if (part.isLast) {
            // shortcut if the multipart sentence only consists of one part
            yield part;
          } else {
            // MAYBE: check if part is not the first one and call a callback (onIncompleteMultipart)?

            // new multipart sentence
            _incompleteSentences.add(part);
          }
        } else {
          final existing = _incompleteSentences[existingIndex];
          existing.appendFrom(part);
          if (part.isLast) {
            yield existing;
            _incompleteSentences.removeAt(existingIndex);
          }
        }

        continue;
      }

      yield sentence;
    }

    for (var incomplete in _incompleteSentences) {
      yield incomplete;
    }
  }

  /// Decodes a raw string into a [NmeaSentence] or [null] if the given string
  /// cannot be decoded. This will also invoke the registered fallback handlers
  /// ([onUnknownProprietarySentence], [onUnknownTalkerSentence], but not
  /// [onUnknownSentence], since it is only used for streaming).
  /// You can handle unknown sentences by checking if the result of this method
  /// is [null] and then invoking the appropriate handler.
  NmeaSentence? decode(String line) {
    if (line.length > 1 && line[1] == nmeaProprietaryDenominator) {
      return decodeProprietary(line);
    }

    if (line.length > 5 && line[5] == nmeaQueryDenominator) {
      return decodeQuery(line);
    }

    return decodeTalker(line);
  }

  /// Tries to decode the given line as a proprietary sentence.
  /// The manufacturer id is extracted from the line and the corresponding
  /// [ProprietarySentenceFactory] is used to create the sentence.
  /// If no factory is registered for the manufacturer id, the fallback
  /// [onUnknownProprietarySentence] is used.
  /// If no fallback is registered, [null] is returned.
  ProprietarySentence? decodeProprietary(String line) {
    for (final manufacturer in _proprietaryGenerators.keys) {
      if (line.startsWith(nmeaProprietaryPrefix + manufacturer)) {
        return _proprietaryGenerators[manufacturer]!(line);
      }
    }

    return onUnknownProprietarySentence?.call(line);
  }

  /// Creates a new instance of [QuerySentence] containing the given line.
  QuerySentence? decodeQuery(String line) {
    return QuerySentence(raw: line);
  }

  /// Tries to decode the given line as a talker sentence.
  /// The mnemonic is extracted from the line and the corresponding
  /// [TalkerSentenceFactory] is used to create the sentence.
  /// If no factory is registered for the mnemonic, the fallback
  /// [onUnknownTalkerSentence] is used.
  /// If no fallback is registered, [null] is returned.
  TalkerSentence? decodeTalker(String line) {
    final separatorIndex = line.indexOf(nmeaFieldSeparator);
    if (separatorIndex < 0 || line.length < 6) {
      return null;
    }

    final rawMnemonic = line.substring(3, separatorIndex);
    for (final generatorMnemonic in _talkerGenerators.keys) {
      if (generatorMnemonic == rawMnemonic) {
        return _talkerGenerators[generatorMnemonic]!(line);
      }
    }

    return onUnknownTalkerSentence?.call(line);
  }
}
