import 'package:nmea/src/limited_size_queue.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('LimitedSizeQueue acts as a normal list', () {
    final queue = LimitedSizeQueue<int>(capacity: 10);

    expect(queue.length, equals(0));

    queue.add(1);

    expect(queue.length, equals(1));

    queue.removeAt(0);

    expect(queue.length, equals(0));
  });

  test('LimitedSizeQueue acts as a queue', () {
    final queue = LimitedSizeQueue<int>(capacity: 5)..addAll([0, 1, 2, 3, 4]);

    expect(queue.isEmpty, isFalse);
    expect(queue.isFull, isTrue);
    expect(queue.pop(), equals(0));
    expect(queue.isNotFull, isTrue);
    expect(queue.isNotEmpty, isTrue);
    expect(queue.pop(), equals(1));
    expect(queue.pop(), equals(2));
    expect(queue.pop(), equals(3));
    expect(queue.pop(), equals(4));
    expect(queue.isEmpty, isTrue);

    expect(queue.pop, throwsRangeError);
  });

  test('LimitedSizeQueue drops head if capacity is reached', () {
    final queue = LimitedSizeQueue<int>(capacity: 5, dropCount: 1)
      ..addAll([0, 1, 2, 3, 4]);

    expect(queue.head, equals(0));
    expect(queue.tail, equals(4));

    queue.add(5);

    expect(queue.head, equals(1));
    expect(queue.tail, equals(5));
  });
}
