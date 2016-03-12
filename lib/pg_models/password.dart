part of pg_models;

@Table("password")
class Password extends PgModel {
  @Field()
  String name;

  @ManyToMany(main: true)
  List<User> users;

  @OneToMany()
  List<Hash> hashes;

  Password() {
    users = new List();
    hashes = new List();
  }
}
