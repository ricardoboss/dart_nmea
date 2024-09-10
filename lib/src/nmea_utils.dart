import 'dart:convert';

/// A utility class for nmea.
class NmeaUtils {
  /// Utility classes should not be instantiated.
  NmeaUtils._();

  /// Calculates the XOR checksum for the given input. The result consists of two
  /// hexadecimal, uppercase characters (00 - FF). The default encoding is US
  /// ASCII, but you can provide your own [encoding] if you wish.
  ///
  /// The checksum is calculated by XOR'ing all bytes in the input together.
  /// The sum is then converted to a radix string with base 16, uppercased and
  /// padded left with zeros.
  static String xorChecksum(String data, {Encoding encoding = ascii}) {
    final bytes = encoding.encode(data);
    var sum = 0;
    for (final byte in bytes) {
      sum ^= byte;
    }

    return sum.toRadixString(16).toUpperCase().padLeft(2, '0');
  }
}
