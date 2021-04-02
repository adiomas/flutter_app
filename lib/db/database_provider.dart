import 'package:flutter_app2/model/Comment.dart';
import 'package:flutter_app2/servises/comment_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseProvider {
  static const String TABLE_COMMENTS = "comments";
  static const String COLUMN_ID = "id";
  static const String COLUMN_NAME = "name";
  static const String COLUMN_EMAIL = "email";
  static const String COLUMN_BODY = "body";

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    print("database getter called");

    if (_database != null) {
      return _database;
    }

    _database = await createDatabase();

    return _database;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'commentsDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print("Creating comments table");

        await database.execute(
          "CREATE TABLE $TABLE_COMMENTS ("
          "$COLUMN_ID INTEGER PRIMARY KEY UNIQUE AUTOINCREMENT,"
          "$COLUMN_NAME TEXT,"
          "$COLUMN_EMAIL TEXT,"
          "$COLUMN_BODY INTEGER"
          ")",
        );
      },
    );
  }

  Future<List<Comment>> getComments() async {
    final db = await database;

    var comments = await db.query(TABLE_COMMENTS,
        columns: [COLUMN_ID, COLUMN_NAME, COLUMN_EMAIL, COLUMN_BODY]);

    List<Comment> commentList = [];

    comments.forEach((currentComment) {
      Comment comment = Comment.fromMap(currentComment);

      commentList.add(comment);
    });

    return commentList;
  }

  void tableIsEmpty() async {
    final db = await database;
    /*await db.execute(
         'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');*/

    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM comments'));
    print('VELIČINA: $count');
  }

  Future<Comment> insert(Comment comment) async {
    final db = await database;
    comment.id = await db.insert(TABLE_COMMENTS, comment.toMap());
    return comment;
  }

  Future<List<Comment>> insertComments({int page}) async {
    final db = await database;

    // var comments = await db.query(TABLE_COMMENTS,
    //     columns: [COLUMN_ID, COLUMN_NAME, COLUMN_EMAIL, COLUMN_BODY]);
    List<Comment> commentList = [];
    commentList = await CommentService.browse(page: page);
    print('aaaaaa $commentList');

    commentList.forEach((currentComment) async {
      Comment comment = currentComment;
      print('Comment $comment');
      comment.id = await db.insert(TABLE_COMMENTS, comment.toMap());
    });

    return commentList;
  }

  Future<int> deleteAllComments() async {
    final db = await database;
    return await db.delete(TABLE_COMMENTS);
  }

  Future<int> delete(int id) async {
    final db = await database;

    return await db.delete(
      TABLE_COMMENTS,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> update(Comment comment) async {
    final db = await database;

    return await db.update(
      TABLE_COMMENTS,
      comment.toMap(),
      where: "id = ?",
      whereArgs: [comment.id],
    );
  }
}
