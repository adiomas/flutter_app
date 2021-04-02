import 'package:flutter_app2/db/database_provider.dart';

class Comment {
  int id;
  String name;
  String email;
  String body;

  Comment({this.id, this.name, this.email, this.body});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_ID: id,
      DatabaseProvider.COLUMN_NAME: name,
      DatabaseProvider.COLUMN_EMAIL: email,
      DatabaseProvider.COLUMN_BODY: body
    };

    if (id != null) {
      map[DatabaseProvider.COLUMN_ID] = id;
    }

    return map;
  }

  Comment.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    name = map[DatabaseProvider.COLUMN_NAME];
    email = map[DatabaseProvider.COLUMN_EMAIL];
    body = map[DatabaseProvider.COLUMN_BODY];
  }
}
