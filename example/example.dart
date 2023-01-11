// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:nmea/nmea.dart' as nmea;

void main() {
  Stream.fromIterable([
    "\$--MSG,A,1,0,0,0,0*29",
    "\$PACME{'test':true}",
    "\$--NOT,REGISTERED,SENTENCE,TEST*1C",
    "\$CST,first,second",
  ])
      .transform(nmea.NmeaDecoder(onlyAllowValid: true)
        ..registerTalkerSentence(
            MsgSentence.id, (line) => MsgSentence(raw: line))
        ..registerProprietarySentence(AcmeProprietarySentence.id,
            (line) => AcmeProprietarySentence(raw: line))
        ..registerCustomChecksumSentence(MyCustomSentence.id,
            (line) => MyCustomSentence(raw: line, validateChecksums: false)))
      .listen((nmea.NmeaSentence sentence) {
    print("${sentence.raw} is a valid ${sentence.type.name} sentence");
  });

  // Output:
  // $--MSG,A,1,0,0,0,0*29 is a valid talker sentence
  // $PACME{'test':true} is a valid proprietary sentence
  // $CST,first,second is a valid custom sentence
}

class MsgSentence extends nmea.TalkerSentence {
  static const String id = "MSG";

  MsgSentence({required super.raw});

  // You can access the fields in this talker sentence by their index
  String get field1 => fields[1];

  int get field2 => int.parse(fields[2]);
}

class AcmeProprietarySentence extends nmea.ProprietarySentence {
  static const String id = "ACME";

  AcmeProprietarySentence({required super.raw}) : super(manufacturer: id);

  // custom data formatting is allowed in proprietary sentences
  String get json => rawWithoutFixtures;

  // custom validation by overriding [valid]
  // remember to call [super.valid]!
  @override
  bool get valid => super.valid && json.isNotEmpty;

  dynamic get data => jsonDecode(json);
}

class MyCustomSentence extends nmea.CustomChecksumSentence {
  static const String id = "CST";

  MyCustomSentence({required super.raw, super.validateChecksums = true})
      : super(identifier: id);

  String get first => fields[0];

  String get second => fields[1];
}
