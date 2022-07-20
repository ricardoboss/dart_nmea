import 'package:nmea/nmea.dart';

/// A multipart sentence allows the decoder to recognize sentences split up into
/// multiple lines and buffer them until all of them have been received.
/// The generic parameter must be the same sentence implementing the
/// [MultipartSentence].
///
/// One example implementation might look like this:
///
/// ```dart
/// class MySplitSentence extends MultipartSentence<MySplitSentence> {
///   static const id = "SPL";
///
///   late List<int> values;
///   bool _complete;
///
///   MySplitSentence({
///     super.raw,
///   }) {
///     values = fields.getRange(3, 5).map((e) => int.parse(e)).toList();
///   }
///
///   @override
///   int get total => int.parse(fields[1]);
///
///   @override
///   int get sequence => int.parse(fields[2]);
///
///   bool get complete => _complete;
///
///   @override
///   void appendFrom(MySplitSentence other) {
///     values.addAll(other.values);
///     _complete = other.isLast;
///   }
/// }
/// ```
abstract class MultipartSentence<T extends MultipartSentence<T>>
    extends TalkerSentence {
  /// The [MultipartSentence] constructor has the same signature as
  /// [TalkerSentence].
  MultipartSentence({required super.raw, super.prefix});

  /// The number of the current part of the sentence. Usually starts at 1 and
  /// ends at [total] (inclusive).
  int get sequence;

  /// The total number of parts of the sentence. If this has the same value as
  /// [sequence], the sentence is complete.
  int get total;

  /// Whether this part of the sentence is the last one (i.e. if [sequence]
  /// and [total] have the same value).
  bool get isLast => sequence == total;

  /// Whether this is the first part of a multipart sentence. The first message
  /// usually has number 1.
  bool get isFirst => sequence == 1;

  /// This method gets invoked on the first message received for a multipart
  /// sentence. It should update the values on the invoked instance using the
  /// values from the [other] message. The type of [other] is given by [T] and
  /// should be of the same type implementing the [MultipartSentence].
  ///
  /// This method should not modify the [other] message as it is discarded
  /// after calling this method.
  void appendFrom(T other);
}
