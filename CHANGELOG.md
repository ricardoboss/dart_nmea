Changelog
=========

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
