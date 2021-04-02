import 'dart:convert' as convert;
import 'package:flutter_app2/model/Comment.dart';
import 'package:http/http.dart' as http;

class CommentService {
  static Future browse({int page}) async {
    List collection;
    List<Comment> _comments;
    var response = await http.get(Uri.https('jsonplaceholder.typicode.com',
        'comments', {'_page': '$page', '_limit': '10'}));
    if (response.statusCode == 200) {
      collection = convert.jsonDecode(response.body);
      _comments = collection.map((json) => Comment.fromMap(json)).toList();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return _comments;
  }
}
