// ignore_for_file: avoid_print

import 'package:flutter_extended_nmea/flutter_extended_nmea.dart' as nmea;

void main() {
  Stream.fromIterable([
    "\$--MSG,A,1,0,0,0,0*29",
    "\$PACME{'test':true}",
    "\$--NOT,REGISTERED,SENTENCE,TEST*1C",
  ])
      .transform(
        nmea.NmeaDecoder(onlyAllowValid: true)
            ..registerTalkerSentence(MsgSentence.id, (line) => MsgSentence(raw: line))
            ..registerProprietarySentence(AcmeProprietarySentence.id, (line) => AcmeProprietarySentence(raw: line))
      )
      .listen((nmea.NmeaSentence sentence) {
    print("${sentence.raw} is a valid ${sentence.type.name} sentence");
  });

  // Output:
  // $--MSG,A,1,0,0,0,0*29 is a valid talker sentence
  // $PACME{'test':true} is a valid proprietary sentence
}

class MsgSentence extends nmea.TalkerSentence {
  static const String id = "MSG";

  MsgSentence({required super.raw});

  // You can access the fields in this talker sentence by their index
  String get status => fields[1];

  int get count => int.parse(fields[2]);

  // etc...
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
}
