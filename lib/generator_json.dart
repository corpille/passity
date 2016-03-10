import 'dart:io';
import 'dart:mirrors';
import "package:passity/models/models.dart";
import 'package:redstone_mapper/mapper.dart';

void main() {
  var pathCurrentFile = Platform.script.toFilePath();
  var modelsDir = new Directory(pathCurrentFile.substring(
          0, pathCurrentFile.lastIndexOf(Platform.pathSeparator)) +
      '/models');
  bool exist = modelsDir.existsSync();
  if (exist == false) {
    print("Error : lib/models non found");
    return;
  }

  var labelStart = "  //==== code generated ====";
  var labelEnd = "  //== end code generated ==";

  ClassMirror cmField = reflectClass(Field);
  ClassMirror cmExpose = reflectClass(Expose);
  // ClassMirror cmCustomBuilder = reflectClass(CustomBuilder);

  modelsDir.listSync(recursive: true, followLinks: false).forEach((file) {
    if (file is File && !file.path.endsWith("model.dart")) {
      var content = file.readAsStringSync();

      var codeGenerate = labelStart + "\n";
      codeGenerate += "  Map toJson() {\n";
      codeGenerate += "    var map = super.toJson();\n";

      var index1 = content.indexOf(r'class ') + 6;
      var index2 = content.indexOf(r' ', index1);
      var className = content.substring(index1, index2);

      MirrorSystem mirrors = currentMirrorSystem();
      LibraryMirror lm = mirrors.libraries.values.firstWhere(
          (LibraryMirror lm) => lm.qualifiedName == new Symbol("models"));
      ClassMirror cm = lm.declarations[new Symbol(className)];
      if (cm == null ||
          !(cm.isSubclassOf(lm.declarations[new Symbol("Model")]))) {
        return;
      }
      InstanceMirror im = cm.newInstance(new Symbol(''), []);
      var decls = cm.declarations.values.where((dm) {
        if ((dm is VariableMirror || (dm is MethodMirror && dm.isGetter)) ==
            false) {
          return false;
        }
        bool ok = false;
        for (var meta in dm.metadata) {
          if (cmField == meta.type || cmExpose == meta.type) {
            ok = true;
            break;
          }
        }
        return ok;
      });
      decls.forEach((dm) {
        String key = MirrorSystem.getName(dm.simpleName);
        var val = im.getField(dm.simpleName).reflectee;

        codeGenerate += "    map['${key}'] = ";
        if (val is Model) {
          codeGenerate += "(${key} == null) ? null : ";
          codeGenerate += "${key}.toJson()";
        } else {
          codeGenerate += key;
        }
        codeGenerate += ";\n";
      });
      codeGenerate += "    return map;\n";
      codeGenerate += "  }\n\n";
      codeGenerate += "  void checkData(Map data) {\n";
      codeGenerate += "    super.checkData(data);\n";
      decls.forEach((dm) {
        String key = MirrorSystem.getName(dm.simpleName);
        var val = im.getField(dm.simpleName).reflectee;
        if (val is List<Model>) {
          var meta = null;
          if (meta != null) {
            codeGenerate +=
                "    if (data.containsKey('${key}') && data['${key}'] is List) {\n";
            codeGenerate +=
                "      data['${key}'].forEach((var data) => ${key}.add(${dm.metadata[1].reflectee}(data)));\n";
            codeGenerate += "    }\n";
            return;
          }
        }
        codeGenerate +=
            "    if (data.containsKey('${key}') && data['${key}'].toString() != ${key}.toString()) ${key} = ";
        if (val is Model) {
          codeGenerate +=
              "new ${MirrorSystem.getName(reflect(val).type.simpleName)}(data['${key}']);";
        } else {
          codeGenerate += "data['${key}'];";
        }
        codeGenerate += "\n";
      });
      codeGenerate += "  }\n\n";
      codeGenerate += "  ${className} clone() {\n";
      codeGenerate += "    var model = new ${className}();\n";
      decls.forEach((dm) {
        String key = MirrorSystem.getName(dm.simpleName);
        var val = im.getField(dm.simpleName).reflectee;
        codeGenerate += "    model.${key} = ";
        if (val is Model) {
          codeGenerate += "${key}?.clone();";
        } else {
          codeGenerate += "${key};";
        }
        codeGenerate += "\n";
      });
      codeGenerate += "    return model;\n";
      codeGenerate += "  }\n\n";
      codeGenerate += '  Model newThis() => new ${className}();\n';
      codeGenerate += labelEnd;

      if (content.contains(labelStart)) {
        var index1 = content.indexOf(labelStart);
        var index2 = content.indexOf(labelEnd) + labelEnd.length;
        var contentTmp = content;
        content = contentTmp.substring(0, index1) +
            codeGenerate +
            contentTmp.substring(index2);
      } else {
        content = content.replaceFirst(r"{", "{\n\n" + codeGenerate);
      }
      file.writeAsStringSync(content);
      print("file : ${file.path} DONE");
    }
  });
}
