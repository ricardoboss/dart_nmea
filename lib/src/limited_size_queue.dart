import 'dart:collection';
import 'dart:math';

class LimitedSizeQueue<T> with ListMixin<T> {
  final int capacity;
  final int dropCount;

  final List<T> _buffer = <T>[];

  LimitedSizeQueue({required this.capacity, int? dropCount})
      : assert(capacity > 0, "The capacity must be a positive integer"),
        assert(dropCount == null || dropCount < capacity,
            "dropCount must be smaller than the capacity"),
        assert(dropCount == null || dropCount > 0,
            "dropCount must be a positive integer"),
        dropCount = dropCount ?? max(capacity ~/ 10, 1);

  @override
  int get length => _buffer.length;

  int get remaining => capacity - _buffer.length;

  bool get isFull => remaining == 0;

  bool get isNotFull => remaining > 0;

  T get head => _buffer.first;

  T get tail => _buffer.last;

  @override
  set length(int newLength) {
    _buffer.length = newLength;
  }

  @override
  T operator [](int index) {
    return _buffer[index];
  }

  @override
  void operator []=(int index, T value) {
    _buffer[index] = value;
  }

  @override
  void add(T element) {
    if (length >= capacity) {
      removeRange(0, dropCount);
    }

    _buffer.add(element);
  }

  T pop() {
    RangeError.checkValidRange(0, 1, length);

    return removeAt(0);
  }
}
