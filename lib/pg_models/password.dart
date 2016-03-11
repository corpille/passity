part of pg_models;

@Table("password")
class Password extends PgModel {
  @Field()
  String name;

  @ManyToMany()
  List<User> users;

  Password() {
    users = new List();
  }
}
