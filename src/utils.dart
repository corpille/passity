part of passity;

class Utils {
  static String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });
    return new String.fromCharCodes(codeUnits);
  }

  static Uint8List padList(Uint8List list, int size) {
    Uint8List padded = new Uint8List(size);
    for (var i = 0; i < size; i++) {
      if (i < list.lengthInBytes) {
        padded[i] = list.elementAt(i);
      }
    }
    return padded;
  }

  static String formatBytesAsHexString(Uint8List bytes) {
    var result = new StringBuffer();
    for (var i = 0; i < bytes.lengthInBytes; i++) {
      var part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return result.toString();
  }

  static String createStringFromHexString(String hex) {
    var charCodes = createUint8ListFromHexString(hex);
    return new String.fromCharCodes(charCodes);
  }

  static Uint8List createUint8ListFromHexString(String hex) {
    var result = new Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      var num = hex.substring(i, i + 2);
      var byte = int.parse(num, radix: 16);
      result[i ~/ 2] = byte;
    }
    return result;
  }
}
