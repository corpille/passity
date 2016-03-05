part of api;

/// Controller that manage all the user queries
@app.Group('/user')
class UserController {
  @app.Route("/", methods: const [app.POST])
  Future addUser(@Decode() User user) async {
    //encode user, and insert it in the "user" table.
    return postgreSql.execute(
        "insert into users (login, password)"
        "values (@login, @password)",
        user);
  }
}
