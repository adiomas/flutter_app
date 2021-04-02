import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app2/events/delete_all_comments.dart';
import 'package:flutter_app2/events/get_comments_from_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'bloc/comment_bloc.dart';
import 'db/database_provider.dart';
import 'events/delete_comment.dart';
import 'events/set_comments.dart';
import 'comment_form.dart';
import 'model/Comment.dart';

class CommentList extends StatefulWidget {
  const CommentList({Key key}) : super(key: key);

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  @override
  void initState() {
    super.initState();
    DatabaseProvider.db.getComments().then((commentList) {
      BlocProvider.of<CommentBloc>(context).add(SetComments(commentList));
    });
  }

  int page = 1;
  bool isLoaded = false;
  RefreshController _refreshController =
      new RefreshController(initialRefresh: false);

  void _onRefresh() async {
    print('Refresh $_refreshController');
    print('IS LOADED: $isLoaded');
    await Future.delayed(Duration(seconds: 2));

    DatabaseProvider.db.deleteAllComments().then((index) {
      print(index);
      BlocProvider.of<CommentBloc>(context).add(DeleteAllComents());
    });
    DatabaseProvider.db.insertComments(page: 1).then((commentList) {
      BlocProvider.of<CommentBloc>(context)
          .add(GetCommentsFromApi(commentList));
    });
    print("SET STATE");
    setState(() {
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading() async {
    page += 1;
    print('page: $page');

    DatabaseProvider.db.insertComments(page: page).then((commentList) {
      BlocProvider.of<CommentBloc>(context)
          .add(GetCommentsFromApi(commentList));
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _refreshController.loadComplete();
    });
  }

  showCommentDialog(BuildContext context, Comment comment, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 30,
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              child: Image.asset('assets/picture1.jpeg')),
        ),
        content: Text(
          "ID:  ${comment.id}\n\nEMAIL:\n${comment.email}\n\nBODY:\n${comment.body}",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CommentForm(comment: comment, commentIndex: index),
              ),
            ),
            child: Text("Update"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter app"),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.settings_input_antenna),
              onPressed: () async {
                DatabaseProvider.db
                    .insertComments(page: page)
                    .then((commentList) {
                  BlocProvider.of<CommentBloc>(context)
                      .add(GetCommentsFromApi(commentList));
                  isLoaded = true;
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                DatabaseProvider.db.deleteAllComments().then((index) {
                  print(index);
                  BlocProvider.of<CommentBloc>(context).add(DeleteAllComents());
                  page = 1;
                  DatabaseProvider.db.tableIsEmpty();
                });
              },
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        child: BlocConsumer<CommentBloc, List<Comment>>(
          builder: (context, commentList) {
            return SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (context, mode) {
                    Widget body;
                    if (mode == LoadStatus.idle)
                      body = Text('Pull up to load');
                    else if (mode == LoadStatus.loading)
                      body = CupertinoActivityIndicator();
                    else if (mode == LoadStatus.failed)
                      body = Text('Load failed! Click to retry');
                    else if (mode == LoadStatus.canLoading)
                      body = Text('Release to load more');
                    else
                      body = Text('No more data');
                    return Container(
                      height: 55.0,
                      child: Center(
                        child: body,
                      ),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    Comment comment = commentList[index];
                    print(comment.toString());
                    return Dismissible(
                      key: ValueKey(comment.id),
                      background: Container(
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).errorColor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text('Jesi li siguran?'),
                            content: Text(
                              'Želiš li ukloniti comment?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('NE'),
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text('DA'),
                                onPressed: () {
                                  Navigator.of(ctx).pop(true);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        DatabaseProvider.db.delete(comment.id).then((_) {
                          BlocProvider.of<CommentBloc>(context).add(
                            DeleteComment(index),
                          );
                        });
                      },
                      child: Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(comment.name.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          onTap: () =>
                              showCommentDialog(context, comment, index),
                        ),
                        color: Colors.blue[400],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                  itemCount: commentList.length,
                ));
          },
          listener: (BuildContext context, commentList) {},
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CommentForm()),
        ),
      ),
    );
  }
}
