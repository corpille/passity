part of services;

@Injectable()
class SrvPassword {
  Dao _dao = new Dao();

  addPassword(Map password) async {
    await _dao.addPassword(password);
  }
}
