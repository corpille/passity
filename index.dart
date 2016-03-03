import "src/passity.dart";
import "package:cipher/impl/server.dart";
import 'dart:io';

int main(List<String> arguments) {
  if (arguments.length != 2) {
    print("./passify login password");
    return -1;
  }
  initCipher();

  var token = Encryption.SHA256(Encryption.SHA512(arguments[1]));
  User user = new User(arguments[0], arguments[1]);

  print("Enter a password");
  var password = stdin.readLineSync();

  print("Encrypting the password ...");
  Password p = new Password();
  p.addHash(user, password, token);

  print("Decrypting the password ...");
  var decrypted_password = p.getPassword(user, token);
  print("Here is your password: " + decrypted_password);

  return 0;
}
