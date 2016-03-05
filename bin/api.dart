library api;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:yaml/yaml.dart';
import 'package:passity/models.dart';
import 'dart:mirrors';

part "index.dart";
part "utils/config.dart";
part "utils/tableCreator.dart";
part "controller/user_controller.dart";

PostgreSql get postgreSql => app.request.attributes.dbConn;
