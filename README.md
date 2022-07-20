# nmea

[![Pipeline](https://github.com/ricardoboss/dart_nmea/actions/workflows/pipeline.yml/badge.svg)](https://github.com/ricardoboss/dart_nmea/actions/workflows/pipeline.yml)

An extensible NMEA0183 parser.

Take a look at the [example](example/example.dart) to see how to use it.

## Usage

```dart
// 1. declare your sentences (use TalkerSentence and ProprietarySentence)
class AbcSentence extends TalkerSentence {
  AbcSentence({required super.raw});
  
  String get data => fields[1];
  
  @override
  bool get valid => super.valid && fields.length == 2;
}

// 2. register your sentences
final decoder = NmeaDecoder()
  ..registerTalkerSentence("ABC", (line) => AbcSentence(raw: line));

// 3. decode a line
final sentence = decoder.decode("\$--ABC,123456789*5D");

// 4. consume your sentences
print(sentence.valid); // true
print(sentence.checksum); // 5D
print(sentence.source); // --
if (sentence is AbcSentence) {
  print(sentence.data); // 123456789
}
```

You can also use it as a StreamTransformer for a stream of Strings:

```dart
final stream = Stream.fromIterable(["\$--ABC,123456789*5D", "\$--DEF,987654321*5D"]);
final transformed = stream.transform(decoder);
transformed.listen((sentence) {
  print(sentence.valid); // true
  print(sentence.checksum); // 5D
  print(sentence.source); // --
  if (sentence is AbcSentence) {
    print(sentence.data); // 123456789
  }
});
```
