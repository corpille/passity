part of pg_models;

@Table("password")
class Password extends PgModel {
  @Field()
  String name;

  @OneToMany()
  List<PasswordRole> passwordroles;

  @OneToMany()
  List<Hash> hashes;

  Password() {
    passwordroles = new List();
    hashes = new List();
  }

  @override
  Future delete() async {
    for (Hash hash in hashes) {
      await hash.delete();
    }
    for (PasswordRole passwordrole in passwordroles) {
      await passwordrole.delete();
    }
    await super.delete();
  }
}
