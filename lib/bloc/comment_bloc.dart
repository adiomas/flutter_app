import 'package:flutter_app2/events/add_comment.dart';
import 'package:flutter_app2/events/comment_event.dart';
import 'package:flutter_app2/events/delete_all_comments.dart';
import 'package:flutter_app2/events/delete_comment.dart';
import 'package:flutter_app2/events/get_comments_from_api.dart';
import 'package:flutter_app2/events/set_comments.dart';
import 'package:flutter_app2/events/update_comment.dart';
import 'package:flutter_app2/model/Comment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentBloc extends Bloc<CommentEvent, List<Comment>> {
  @override
  List<Comment> get initialState => [];

  @override
  Stream<List<Comment>> mapEventToState(CommentEvent event) async* {
    if (event is SetComments) {
      yield event.commentList;
    } else if (event is AddComment) {
      List<Comment> newState = List.from(state);
      if (event.newComment != null) {
        newState.add(event.newComment);
      }
      yield newState;
    } else if (event is DeleteComment) {
      List<Comment> newState = List.from(state);
      newState.removeAt(event.commentIndex);
      yield newState;
    } else if (event is UpdateComment) {
      List<Comment> newState = List.from(state);
      newState[event.commentIndex] = event.newComment;
      yield newState;
    } else if (event is GetCommentsFromApi) {
      List<Comment> newState = List.from(state);
      if (event.commentList != null) {
        event.commentList.forEach((element) {
          newState.add(element);
        });
      }
      yield newState;
    } else if (event is DeleteAllComents) {
      List<Comment> newState = List.from(state);
      newState.clear();
      yield newState;
    }
  }
}
