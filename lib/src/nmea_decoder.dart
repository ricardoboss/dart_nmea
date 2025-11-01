import 'dart:async';
import 'dart:convert';

import 'package:nmea/src/custom_checksum_sentence.dart';
import 'package:nmea/src/custom_sentence.dart';
import 'package:nmea/src/limited_size_queue.dart';
import 'package:nmea/src/multipart_sentence.dart';
import 'package:nmea/src/nmea_sentence.dart';
import 'package:nmea/src/proprietary_sentence.dart';
import 'package:nmea/src/query_sentence.dart';
import 'package:nmea/src/talker_sentence.dart';

/// A function to create a [CustomSentence] from a raw string and an
/// identifier.
typedef CustomSentenceFactory = CustomSentence Function(String line);

/// A function to create a [CustomChecksumSentence] from a raw string and an
/// identifier.
typedef CustomChecksumSentenceFactory = CustomChecksumSentence Function(
  String line,
);

/// A function to create a [ProprietarySentence] from a raw string and a
/// manufacturer id.
typedef ProprietarySentenceFactory = ProprietarySentence Function(String line);

/// A function to create a [TalkerSentence] from a raw string.
typedef TalkerSentenceFactory = TalkerSentence Function(String line);

/// A fallback function to create a [ProprietarySentence] from a raw string.
/// May return `null` if no conversion is available.
typedef OptionalProprietarySentenceFactory = ProprietarySentence? Function(
  String line,
);

/// A fallback function to create a [TalkerSentence] from a raw string. May
/// return `null` if no conversion is available.
typedef OptionalTalkerSentenceFactory = TalkerSentence? Function(String line);

/// A fallback function to create a [NmeaSentence] from a raw string. May
/// return `null` if no conversion is available.
typedef OptionalNmeaSentenceFactory = NmeaSentence? Function(String line);

/// A handler for multipart sequences that no 'first' part exists for.
/// Can return a multipart sentence that then serves as the 'first' sentence.
typedef OnIncompleteMultipartSentence = MultipartSentence? Function(
  MultipartSentence<dynamic> sentence,
);

/// A [StreamTransformer] that splits [String] lines into NMEA0183 sentence
/// objects ([NmeaSentence]).
///
/// This transformer would typically be used after a [LineSplitter], because
/// this transformer doesn't buffer the input and tries to parse every piece of
/// data it receives as a complete NMEA sentence.
class NmeaDecoder extends StreamTransformerBase<String, NmeaSentence> {
  /// Creates a new [NmeaDecoder] that only streams NMEA0183 sentences.
  /// You can pass functions to handle unknown sentences for different types.
  /// As a general callback, [onUnknownSentence] can be used.
  /// If you only want this stream transformer to pass on valid NMEA0183
  /// sentences, set [onlyAllowValid] to true.
  NmeaDecoder({
    this.onUnknownProprietarySentence,
    this.onUnknownTalkerSentence,
    this.onUnknownSentence,
    this.onIncompleteMultipartSentence,
    this.onlyAllowValid = false,
  });

  final Map<String, CustomSentenceFactory> _customGenerators = {};
  final Map<String, CustomChecksumSentenceFactory> _customChecksumGenerators =
      {};
  final Map<String, OptionalProprietarySentenceFactory> _proprietaryGenerators =
      {};
  final Map<String, TalkerSentenceFactory> _talkerGenerators = {};
  final LimitedSizeQueue<MultipartSentence> _incompleteSentences =
      LimitedSizeQueue(capacity: 100, dropCount: 10);

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

  /// Get invoked for multipart sequences that no 'first' part exists for.
  /// Can return a multipart sentence that then serves as the 'first' sentence.
  final OnIncompleteMultipartSentence? onIncompleteMultipartSentence;

  /// Whether or not this decoder only streams valid NMEA0183 sentences.
  /// Invalid sentences are silently ignored.
  final bool onlyAllowValid;

  /// Registers a [CustomSentenceFactory] for a given identifier.
  void registerCustomSentence(
    String identifier,
    CustomSentenceFactory factory,
  ) {
    _customGenerators[identifier] = factory;
  }

  /// Registers a [CustomChecksumSentenceFactory] for a given identifier.
  void registerCustomChecksumSentence(
    String identifier,
    CustomChecksumSentenceFactory factory,
  ) {
    _customChecksumGenerators[identifier] = factory;
  }

  /// Registers a [ProprietarySentenceFactory] for a given manufacturer id.
  void registerProprietarySentence(
    String manufacturer,
    OptionalProprietarySentenceFactory factory,
  ) {
    _proprietaryGenerators[manufacturer] = factory;
  }

  /// Registers a [TalkerSentenceFactory] for a given mnemonic.
  void registerTalkerSentence(String mnemonic, TalkerSentenceFactory factory) {
    _talkerGenerators[mnemonic] = factory;
  }

  @override
  Stream<NmeaSentence> bind(Stream<String> stream) async* {
    await for (final line in stream) {
      final sentence = decode(line);
      if (sentence != null) {
        yield sentence;
      }
    }

    for (final incomplete in _incompleteSentences) {
      yield incomplete;
    }
  }

  /// Decodes a raw string into a [NmeaSentence] or `null` if the given string
  /// cannot be decoded. This will also invoke the registered fallback handlers
  /// ([onUnknownProprietarySentence], [onUnknownTalkerSentence], but not
  /// [onUnknownSentence], since it is only used for streaming).
  /// You can handle unknown sentences by checking if the result of this method
  /// is `null` and then invoking the appropriate handler.
  NmeaSentence? decode(String line) {
    NmeaSentence? sentence;

    if (line.length > 1 && line[1] == nmeaProprietaryDenominator) {
      sentence = decodeProprietary(line);
    } else if (line.length > 5 && line[5] == nmeaQueryDenominator) {
      sentence = decodeQuery(line);
    } else {
      sentence = decodeTalker(line) ??
          decodeCustomChecksum(line) ??
          decodeCustom(line);
    }

    sentence ??= onUnknownSentence?.call(line);

    if (sentence == null || (onlyAllowValid && !sentence.valid)) {
      return null;
    }

    if (sentence is MultipartSentence) {
      final existingIndex = _incompleteSentences.indexWhere(sentence.belongsTo);
      if (existingIndex < 0) {
        if (sentence.isLast) {
          // shortcut if the multipart sentence only consists of one part
          return sentence;
        } else if (sentence.isFirst) {
          // new multipart sentence
          _incompleteSentences.add(sentence);
        } else {
          // 'mid-sequence' multipart sentence (we didn't get the first one)
          final fallback = onIncompleteMultipartSentence?.call(sentence);
          if (fallback != null) {
            fallback.appendFrom(sentence);
            _incompleteSentences.add(fallback);
          }
        }
      } else {
        final existing = _incompleteSentences[existingIndex]
          ..appendFrom(sentence);

        if (sentence.isLast) {
          _incompleteSentences.removeAt(existingIndex);
          return existing;
        }
      }

      return null;
    }

    return sentence;
  }

  /// Tries to decode the given line as a custom sentence.
  /// The identifier is extracted from the line and the corresponding
  /// [CustomSentenceFactory] is used to create the sentence.
  /// If none is found `null` is returned.
  CustomSentence? decodeCustom(String line) {
    for (final identifier in _customGenerators.keys) {
      if (line.startsWith(nmeaPrefix + identifier)) {
        return _customGenerators[identifier]!(line);
      }
    }

    return null;
  }

  /// Tries to decode the given line as a custom sentence with a checksum.
  /// The identifier is extracted from the line and the corresponding
  /// [CustomChecksumSentenceFactory] is used to create the sentence.
  /// If none is found `null` is returned.
  CustomChecksumSentence? decodeCustomChecksum(String line) {
    for (final identifier in _customChecksumGenerators.keys) {
      if (line.startsWith(nmeaPrefix + identifier)) {
        return _customChecksumGenerators[identifier]!(line);
      }
    }

    return null;
  }

  /// Tries to decode the given line as a proprietary sentence.
  /// The manufacturer id is extracted from the line and the corresponding
  /// [ProprietarySentenceFactory] is used to create the sentence.
  /// If no factory is registered for the manufacturer id, the fallback
  /// [onUnknownProprietarySentence] is used.
  /// If no fallback is registered, `null` is returned.
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
  /// If no fallback is registered, `null` is returned.
  TalkerSentence? decodeTalker(String line) {
    final separatorIndex = line.indexOf(nmeaFieldSeparator);
    if (separatorIndex < 3 || line.length < 6) {
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
