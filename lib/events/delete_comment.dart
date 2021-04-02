import 'comment_event.dart';

class DeleteComment extends CommentEvent {
  int commentIndex;

  DeleteComment(int index) {
    commentIndex = index;
  }
}
