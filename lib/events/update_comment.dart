import 'package:flutter_app2/model/Comment.dart';

import 'comment_event.dart';

class UpdateComment extends CommentEvent {
  Comment newComment;
  int commentIndex;

  UpdateComment(int index, Comment comment) {
    newComment = comment;
    commentIndex = index;
  }
}
