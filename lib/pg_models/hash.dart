part of pg_models;

@Table("hash")
class Hash extends PgModel {
  @ManyToOne()
  Password password;

  @Field()
  String identifer;

  @Field()
  String hash;

  @Field()
  int pos;

  @Field()
  int size;

  Hash();

  Hash.fromPassword(String userKey, String password, String token) {
    var decodedKey = _decodeKey(userKey, token);
    var cipher = _createRandomCipher(password);
    var keyChain = new Uint8List.fromList(decodedKey.codeUnits);
    var secure_password = Encryption.AES(cipher, keyChain);
    identifer = Encryption.SHA512(decodedKey);
    hash = Utils.formatBytesAsHexString(secure_password);
    pos = cipher.indexOf(password);
    size = password.length;
  }

  bool isGoodHash(String userKey, String token) {
    var decodedKey = _decodeKey(userKey, token);
    return identifer == Encryption.SHA512(decodedKey);
  }

  String getPassword(String userKey, String token) {
    var key = _decodeKey(userKey, token);
    var secure_password = Utils.createStringFromHexString(hash);
    var keyChain = new Uint8List.fromList(key.codeUnits);
    var password = Encryption.AES(secure_password, keyChain, encode: false);
    var cipher = new String.fromCharCodes(password);
    return cipher.substring(pos, pos + size);
  }

  String _decodeKey(String key, String token) {
    var keyChain = Utils.createUint8ListFromHexString(key);
    var realKey = new String.fromCharCodes(keyChain);
    var tokenChain = Utils.createUint8ListFromHexString(token);
    var decoded = Encryption.AES(realKey, tokenChain, encode: false);
    var decodedKey = new String.fromCharCodes(decoded);
    return decodedKey.substring(0, Encryption.KEY_SIZE);
  }

  String _createRandomCipher(String data) {
    var rand = new Random();
    var rStr = Utils.randomString(Encryption.CIPHER_SIZE);
    var pos = rand.nextInt(Encryption.CIPHER_SIZE);
    var cipher = rStr.substring(0, pos) + data + rStr.substring(pos + 1);
    return cipher;
  }
}
