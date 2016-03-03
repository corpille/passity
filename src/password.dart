part of passity;

class Password {
  Map<String, String> h;
  Map<String, List> p;

  Password() {
    h = new Map<String, String>();
    p = new Map<String, List>();
  }

  void addHash(User u, String password, String token) {
    var key = _decodeKey(u, token);
    var cipher = _createRandomCipher(password);
    var keyChain = new Uint8List.fromList(key.codeUnits);
    var secure_password = Encryption.AES(cipher, keyChain);
    key = Encryption.SHA512(key);
    h[key] = Utils.formatBytesAsHexString(secure_password);
    p[key] = [cipher.indexOf(password), password.length];
  }

  String getPassword(User u, String token) {
    var key = _decodeKey(u, token);
    var hash = h[Encryption.SHA512(key)];
    var secure_password = Utils.createStringFromHexString(hash);
    var keyChain = new Uint8List.fromList(key.codeUnits);
    var password = Encryption.AES(secure_password, keyChain, encode: false);
    var cipher = new String.fromCharCodes(password);
    var pos = p[Encryption.SHA512(key)];
    return cipher.substring(pos[0], pos[0] + pos[1]);
  }

  String _decodeKey(User user, String token) {
    var keyChain = Utils.createUint8ListFromHexString(user.key);
    var realKey = new String.fromCharCodes(keyChain);
    var tokenChain = Utils.createUint8ListFromHexString(token);
    var decoded = Encryption.AES(realKey, tokenChain, encode: false);
    var key = new String.fromCharCodes(decoded);
    return key.substring(0, Encryption.KEY_SIZE);
  }

  String _createRandomCipher(String data) {
    var rand = new Random();
    var rStr = Utils.randomString(Encryption.CIPHER_SIZE);
    var pos = rand.nextInt(Encryption.CIPHER_SIZE);
    var cipher = rStr.substring(0, pos) + data + rStr.substring(pos + 1);
    return cipher;
  }

  String toString() {
    return "{\n" + "\th: ${h},\n" + "\tp: ${p},\n" + "}";
  }
}
