part of pg_models;

@Table("password")
class Password extends PgModel {
  @Field()
  String name;
}
