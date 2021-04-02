import 'package:flutter_app2/model/Comment.dart';

import 'comment_event.dart';

class AddComment extends CommentEvent {
  Comment newComment;

  AddComment(Comment comment) {
    newComment = comment;
  }
}
