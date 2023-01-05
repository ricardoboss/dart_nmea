Changelog
=========

Version 2.1.1
-------------

* Added `LimitedSizeQueue` to fix #4 (Limit size of `_incompleteSentences` in `NmeaDecoder`)

Version 2.1.0
-------------

* Adds support for custom sentence types

Version 2.0.0
-------------

* Renamed project from `flutter_extended_nmea` to `nmea`

Version 1.3.0
-------------

* Removed dependency on `flutter` and `flutter_lints`
* Added some flutter linter rules
* Added GitHub actions workflow for automated testing

Version 1.2.1
-------------

* Allow `null` to be returned from `OptionalTalkerSentenceFactory`

Version 1.2.0
-------------

* Added more constraints on the generic parameter of `MultipartSentence` to only allow the same type
  extending as a parameter

Version 1.1.0
-------------

* Removed unnecessary dependency on cupertino_icons
* Added support for multipart NMEA sentences (like GSV)

Version 1.0.1
-------------

* Fixed error in decoder if sentence doesn't contain a field separator (",")

Version 1.0.0+1
-------------

Initial release.

* Added `NmeaSentence`, `NmeaSentenceType`, `ChecksumSentence`, `TalkerSentence`, `QuerySentence`,
  `ProprietarySentence`, `NmeaUtils` and `NmeaDecoder` classes.