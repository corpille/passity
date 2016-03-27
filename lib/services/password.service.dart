part of services;

@Injectable()
class SrvPassword {
  Dao _dao = new Dao();

  List<Password> passwords;

  addPassword(Map password) async {
    if (passwords == null) {
      passwords = new List();
    }
    passwords.add(await _dao.addPassword(password));
  }

  deletePassword(String id) async {
    await _dao.deletePassword(id);
    passwords.removeWhere((Password password) => password.id == id);
  }

  getPasswordByUser(String userId) async {
    passwords = await _dao.getPasswordByUser(userId);
  }

  Future<String> getDecodePassword(String id) async {
    var result = await _dao.getDecodePassword(id);
    return result["decoded"].toString();
  }
}
