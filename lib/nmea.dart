/// NMEA
/// ====================
///
/// Ported from [ricardoboss/extended-nmea](https://github.com/ricardoboss/extended-nmea).
///
/// This library enables you to decode NMEA0183 sentences from a stream of
/// strings. You can also register proprietary sentences and custom talker
/// sentences.
library nmea;

export 'src/checksum_sentence.dart'
    show ChecksumSentence, nmeaChecksumSeparator;
export 'src/custom_checksum_sentence.dart' show CustomChecksumSentence;
export 'src/custom_sentence.dart' show CustomSentence;
export 'src/multipart_sentence.dart' show MultipartSentence;
export 'src/nmea_decoder.dart'
    show
        CustomSentenceFactory,
        NmeaDecoder,
        OptionalNmeaSentenceFactory,
        OptionalProprietarySentenceFactory,
        OptionalTalkerSentenceFactory,
        ProprietarySentenceFactory,
        TalkerSentenceFactory;
export 'src/nmea_sentence.dart'
    show NmeaSentence, nmeaFieldSeparator, nmeaPrefix, nmeaSuffix;
export 'src/nmea_sentence_type.dart' show NmeaSentenceType;
export 'src/nmea_utils.dart' show NmeaUtils;
export 'src/proprietary_sentence.dart'
    show ProprietarySentence, nmeaProprietaryDenominator, nmeaProprietaryPrefix;
export 'src/query_sentence.dart' show QuerySentence, nmeaQueryDenominator;
export 'src/talker_sentence.dart' show TalkerSentence;
