part of pg_models;

enum UserType { ADMIN, EDIT, READ }

@Table("password_role")
class PasswordRole extends PgModel {
  @ManyToOne()
  User user;

  @ManyToOne()
  Password password;

  @Field(view: "role")
  int role = UserType.READ.index;
}
