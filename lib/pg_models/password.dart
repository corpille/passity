part of pg_models;

@Table("password")
class Password extends PgModel {
  @Field()
  String name;

  @OneToMany()
  List<PasswordRole> passwordrole;

  @OneToMany()
  List<Hash> hashes;

  Password() {
    passwordrole = new List();
    hashes = new List();
  }
}
