import 'package:test/test.dart';
import 'package:nmea/nmea.dart';

void main() {
  test('xorChecksum calculates the correct checksum', () {
    expect(NmeaUtils.xorChecksum("--ROT,0.12,A"), equals("15"));
    expect(NmeaUtils.xorChecksum("--HDT,359.9,T"), equals("24"));
    expect(NmeaUtils.xorChecksum("--NAV,0.05,2.3"), equals("6D"));
  });

  test('xorChecksum returns 0 for empty strings', () {
    expect(NmeaUtils.xorChecksum(""), equals("00"));
  });
}
