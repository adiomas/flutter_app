import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/comment_bloc.dart';
import 'db/database_provider.dart';
import 'events/add_comment.dart';
import 'events/update_comment.dart';
import 'model/Comment.dart';

class CommentForm extends StatefulWidget {
  final Comment comment;
  final int commentIndex;

  CommentForm({this.comment, this.commentIndex});

  @override
  State<StatefulWidget> createState() {
    return CommentFormState();
  }
}

class CommentFormState extends State<CommentForm> {
  String _name;
  String _email;
  String _body;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      initialValue: _name,
      decoration: InputDecoration(labelText: 'Name'),
      style: TextStyle(fontSize: 28),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _name = value;
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      initialValue: _email,
      decoration: InputDecoration(labelText: 'Email'),
      style: TextStyle(fontSize: 28),
      validator: (String value) {
        if (!EmailValidator.validate(value)) {
          return 'Email is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _email = value;
      },
    );
  }

  Widget _buildBody() {
    return TextFormField(
      initialValue: _body,
      decoration: InputDecoration(labelText: 'Body'),
      style: TextStyle(fontSize: 28),
      onSaved: (String value) {
        _body = value;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      _name = widget.comment.name;
      _email = widget.comment.email;
      _body = widget.comment.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comment Form")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildName(),
              _buildEmail(),
              _buildBody(),
              SizedBox(height: 20),
              widget.comment == null
                  ? ElevatedButton(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }

                        _formKey.currentState.save();

                        Comment comment = Comment(
                          name: _name,
                          email: _email,
                          body: _body,
                        );

                        DatabaseProvider.db.insert(comment).then(
                              (storedComment) =>
                                  BlocProvider.of<CommentBloc>(context).add(
                                AddComment(storedComment),
                              ),
                            );

                        Navigator.pop(context);
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          child: Text(
                            "Update",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              print("form");
                              return;
                            }

                            _formKey.currentState.save();

                            Comment comment = Comment(
                              name: _name,
                              email: _email,
                              body: _body,
                            );
                            DatabaseProvider.db.update(widget.comment).then(
                                  (storedComment) =>
                                      BlocProvider.of<CommentBloc>(context).add(
                                    UpdateComment(comment.id, comment),
                                  ),
                                );

                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
