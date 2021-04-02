import 'package:flutter_app2/model/Comment.dart';

import 'comment_event.dart';

class SetComments extends CommentEvent {
  List<Comment> commentList;

  SetComments(List<Comment> comments) {
    commentList = comments;
  }
}
