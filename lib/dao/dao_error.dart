part of dao;

class DaoError extends Error {
  int status;
  String text;

  DaoError(this.status, this.text);

  String toString() {
    if (text == null) {
      return "Error status : ${status}";
    }
    return "Error ${status} / ${text}";
  }
}
