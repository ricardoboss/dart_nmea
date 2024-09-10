Changelog
=========

Version 3.3.0
-------------

* Bumped SDK constraint to >=3.0.0 <4.0.0
* (internal) stricter linting rules
* Fixed docs
* `CustomChecksumSentence` now only evaluates checksums if `validateChecksums` is `true` (default)

Version 3.2.0
-------------

* Moved `MultipartSentence` logic to `decode` method

Version 3.1.0
-------------

* Added `CustomChecksumSentence` and changed parent of `CustomSentence` to `NmeaSentence`.
* Added `NmeaSentenceType.custom` for custom sentences.

Version 3.0.0
-------------

* Breaking: `MultipartSentence` has a new parent class `NmeaSentence` and requires implementations
  for some new abstract members.
* Added `onIncompleteMultipartSentence` to `NmeaDecoder` for handling multipart sentence without
  having received a first sentence part.

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