part of passity;

class Encryption {
  static final int KEY_SIZE = 32;
  static final int CIPHER_SIZE = 42;

  static String SHA256(String plain) {
    var digest = new Digest("SHA-256");
    var plainChain = new Uint8List.fromList(plain.codeUnits);
    var digestChain = digest.process(plainChain);
    return Utils.formatBytesAsHexString(digestChain);
  }

  static String SHA512(String plain) {
    var digest = new Digest("SHA-512");
    var plainChain = new Uint8List.fromList(plain.codeUnits);
    var digestChain = digest.process(plainChain);
    return Utils.formatBytesAsHexString(digestChain);
  }

  static Uint8List AES(String plain, Uint8List key, {bool encode: true}) {
    var params = new KeyParameter(key);
    var cipher = new BlockCipher("AES")..init(encode, params);
    String res = "";
    for (var i = 0; i < plain.length; i += 16) {
      var max = (i + 16 > plain.length) ? plain.length : i + 16;
      var inputBuffer = plain.substring(i, max).codeUnits;
      var plainChain = new Uint8List.fromList(inputBuffer);
      if (plainChain.lengthInBytes < 16) {
        plainChain = Utils.padList(plainChain, 16);
      }
      try {
        var cipherChain = cipher.process(plainChain);
        res += Utils.formatBytesAsHexString(cipherChain);
      } catch (e) {}
    }
    return Utils.createUint8ListFromHexString(res);
  }
}
