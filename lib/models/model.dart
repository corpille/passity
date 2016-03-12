part of models;

abstract class Model {
  String id;

  /// Transform the current class into a Map
  /// in order to be treated by the JSON functions
  Map toJson() {
    Map map = new Map();
    if (this.id != null && this.id != "") {
      map["id"] = this.id;
    }
    return map;
  }

  void checkData(Map data) {
    if (data.containsKey('id') &&
        data['id'] is String &&
        data['id'].isNotEmpty) {
      id = data['id'];
    }
  }

  Model newThis();

  String toString() {
    return JSON.encode(toJson());
  }
}
