/// Flutter Extended NMEA
/// ====================
///
/// Ported from [ricardoboss/extended-nmea](https://github.com/ricardoboss/extended-nmea).
///
/// This library enables you to decode NMEA0183 sentences from a stream of
/// strings. You can also register proprietary sentences and custom talker
/// sentences.
library flutter_extended_nmea;

export 'src/nmea_sentence.dart'
    show NmeaSentence, nmeaPrefix, nmeaSuffix, nmeaFieldSeparator;
export 'src/proprietary_sentence.dart'
    show ProprietarySentence, nmeaProprietaryDenominator, nmeaProprietaryPrefix;
export 'src/talker_sentence.dart' show TalkerSentence;
export 'src/multipart_sentence.dart' show MultipartSentence;
export 'src/query_sentence.dart' show QuerySentence, nmeaQueryDenominator;
export 'src/checksum_sentence.dart'
    show ChecksumSentence, nmeaChecksumSeparator;
export 'src/nmea_decoder.dart'
    show
        NmeaDecoder,
        ProprietarySentenceFactory,
        TalkerSentenceFactory,
        OptionalProprietarySentenceFactory,
        OptionalTalkerSentenceFactory,
        OptionalNmeaSentenceFactory;
export 'src/nmea_sentence_type.dart' show NmeaSentenceType;
export 'src/nmea_utils.dart' show NmeaUtils;
