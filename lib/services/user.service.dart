part of services;

@Injectable()
class SrvUser {
  Dao _dao = new Dao();

  Future createUser(User user) async {
    await _dao.createUser(user);
  }
}
