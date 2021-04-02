import 'package:flutter_app2/model/Comment.dart';

import 'comment_event.dart';

class GetCommentsFromApi extends CommentEvent {
  List<Comment> commentList;

  GetCommentsFromApi(List<Comment> comments) {
    commentList = comments;
  }
}
