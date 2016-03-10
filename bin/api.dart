library api;

/// Core libraries
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

/// Pub libraries
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:dart_jwt/dart_jwt.dart';
import "package:cipher/impl/server.dart";
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper_factory.dart';

/// Local libraries
import 'package:passity/pg_models/pg_models.dart';
import 'package:passity/tools/tools.dart';

/// Controllers
part "controller/api_controller.dart";
part "controller/user_controller.dart";
part "controller/password_controller.dart";

/// Utils
part "utils/config.dart";
part "utils/session.dart";
part "utils/security.dart";
part "utils/error_response.dart";
part "utils/table_creator.dart";

part "index.dart";

/// Database instance
PostgreSql get postgreSql => app.request.attributes.dbConn;
