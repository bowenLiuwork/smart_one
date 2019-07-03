import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_one/business/note_book_data_helper.dart';
import 'package:smart_one/util/device_size_manager.dart';

///
/// 编辑笔记本页面
///
class EditNotePage extends StatefulWidget {
  int noteId;
  NoteEntity noteEntity;

  EditNotePage({Key key, this.noteId = null, this.noteEntity})
      : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool isCreateNewNote = false;
  NoteEntity note;

  _onSaveClick() async {
    var _form = _formKey.currentState;
    _form.save();
    if (note != null) {
      if (note.title == null || note.title.isEmpty) {
        note.title = "新建记事本";
      }
      int time = DateTime.now().millisecondsSinceEpoch;
      if (isCreateNewNote) {
        note.createTime = time;
      }
      note.updateTime = time;

      bool isOK = false;
      if (isCreateNewNote) {
        NoteEntity noteEntity =
            await NoteBookDBHelper.instance.getDBProvider().insert(note);
        isOK = noteEntity.id != 0;
      } else {
        int id = await NoteBookDBHelper.instance.getDBProvider().update(note);
        isOK = id != 0;
      }

      if (!isOK) {
        Fluttertoast.showToast(
            msg: "保存失败",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.black,
            fontSize: 16.0);
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  void initState() {
    NoteBookDBHelper.instance.open();
    isCreateNewNote = widget.noteId == null || widget.noteId < 0;
    if (!isCreateNewNote) {
      note = widget.noteEntity;
      Future<NoteEntity> future =
          NoteBookDBHelper.instance.getDBProvider().getNoteById(widget.noteId);
      future.then((value) {
        note = value;
      });
    } else {
      note = new NoteEntity();
    }
    super.initState();
  }

  @override
  void dispose() {
    print('close ------- edit page --- dispose');
    super.dispose();
    NoteBookDBHelper.instance.close();
  }

  TextFormField buildNoteTitleTextField() {
    return TextFormField(
      initialValue: isCreateNewNote ? "" : note?.title,
      decoration: InputDecoration(
        hintText: "新建记事本",
        hintStyle: TextStyle(color: Colors.black),
      ),
      validator: (String value) {
        return value;
      },
      onSaved: (String value) {
        print('title -- $value');
        note.title = value;
      },
    );
  }

  Widget buildContentTextField() {
    num lines = (DeviceSizeManager.instance.getScreenHeight() - 55) / 20;
    print("text line === $lines");
    return Expanded(
        child: TextFormField(
      initialValue: isCreateNewNote ? "" : note?.content,
      maxLength: 10000,
      maxLines: lines.toInt(),
      textAlign: TextAlign.start,
      validator: (String value) {
        return value;
      },
      onSaved: (String value) {
        print(value);
        note.content = value;
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = new Scaffold(
      appBar: AppBar(
        title: Text("记事本"),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              _onSaveClick();
            },
            child: SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: Text("保存"),
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            buildNoteTitleTextField(),
            buildContentTextField(),
          ],
        ),
      ),
    );

    return scaffold;
  }
}
