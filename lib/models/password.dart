part of models;

class Password extends Model {

  //==== code generated ====
  Map toJson() {
    var map = super.toJson();
    map['name'] = name;
    return map;
  }

  void checkData(Map data) {
    super.checkData(data);
    if (data.containsKey('name') && data['name'].toString() != name.toString()) name = data['name'];
  }

  Password clone() {
    var model = new Password();
    model.name = name;
    return model;
  }

  Model newThis() => new Password();
  //== end code generated ==
  @Expose()
  String name;
}
