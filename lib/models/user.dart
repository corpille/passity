part of models;

@Table("users")
class User extends Model {
  @Field()
  String login;

  @Field()
  String password;

  @Field()
  String key;
}
