import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/business/note_book_data_helper.dart';
import 'package:smart_one/page/edit_note_page.dart';
import 'package:smart_one/util/string_utils.dart';
import 'package:smart_one/util/text_config.dart';

class NoteBookList extends StatefulWidget {
  @override
  _NoteBookListState createState() => _NoteBookListState();
}

class _NoteBookListState extends State<NoteBookList> {
  List<INoteItem> _list = [];
  bool _isEditAble = false;

  void _onEditClick() {
    if (_list != null && _list.isNotEmpty) {
      bool isEdit = _list[0].isCouldEdit();
      for (INoteItem item in _list) {
        item.setEditAble(!isEdit);
      }
      setState(() {
        _isEditAble = !isEdit;
        _list = _list;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() async {
    await NoteBookDBHelper.instance.open();
    List<INoteItem> showList = null;
    List<NoteEntity> temp =
        await NoteBookDBHelper.instance.getDBProvider().getNotesAll();
    if (temp != null) {
      showList = temp.map((item) {
        return new NoteItem(noteEntity: item);
      }).toList();
    }
    await NoteBookDBHelper.instance.close();
    if (showList != null) {
      setState(() {
        _list = showList;
      });
    } else {
      print("no data use------");
    }
  }

  bool _hasNeedDeleteData() {
    if (_list != null && _list.isNotEmpty) {
      for (int i = 0; i < _list.length; i++) {
        INoteItem item = _list[i];
        if (item.isSelected()) {
          return true;
        }
      }
    }
    return false;
  }

  _goEditPage(int noteId, {NoteEntity note}) {
    Future<bool> future = Navigator.of(context, rootNavigator: true)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new EditNotePage(
        noteId: noteId,
        noteEntity: note,
      );
    }));
    future.then((isNeedUpdate) {
      _updateNoteList();
    });
  }

  _deleteData() async {
    try {
      List<NoteEntity> deleteList = [];
      if (_list != null && _list.isNotEmpty) {
        for (int i = 0; i < _list.length; i++) {
          INoteItem item = _list[i];
          if (item.isSelected()) {
            deleteList.add(item.getData());
            _list.removeAt(i);
            i--;
          }
        }
      }
      if (deleteList.isNotEmpty) {
        await NoteBookDBHelper.instance.open();
        for (NoteEntity note in deleteList) {
          await NoteBookDBHelper.instance.getDBProvider().delete(note.id);
        }
        await NoteBookDBHelper.instance.close();
      }

      setState(() {
        _list = _list;
      });
    } catch (e) {
      print('delete data exception --- $e');
    }
  }

  _onDeleteClick() {
    if (!_hasNeedDeleteData()) {
      return;
    }
    AlertDialog alertDialog = new AlertDialog(
      title: Text("确定删除数据？"),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              _deleteData();
            },
            child: Text("确定")),
        FlatButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("取消")),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  _onCancelClick() {
    bool isEdit = false;
    if (_list != null && _list.isNotEmpty) {
      for (INoteItem item in _list) {
        item.setEditAble(isEdit);
      }
    }
    setState(() {
      _isEditAble = isEdit;
      _list = _list;
    });
  }

  @override
  Widget build(BuildContext context) {
    Column column = new Column(
      children: <Widget>[
        SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              Text(
                "记事本",
                style: TextConfig.getTextStyle(
                  size: TextConfig.CONTENT_TEXT_BIG_SIZE,
                ),
              ),
              Expanded(child: Container()),
              Container(
                width: 120,
                child: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: <Widget>[
                    Offstage(
                      offstage: _isEditAble,
                      child: FlatButton(
                        onPressed: () {
                          _onEditClick();
                        },
                        child: Text(
                          "编辑",
                          style: TextConfig.getTextStyle(
                              size: 12, color: Colors.black),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: !_isEditAble,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                child: FlatButton(
                              onPressed: () {
                                _onDeleteClick();
                              },
                              child: Text(
                                "删除",
                                style: TextConfig.getTextStyle(
                                    size: 12, color: Colors.black),
                              ),
                            )),
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  _onCancelClick();
                                },
                                child: Text(
                                  "取消",
                                  style: TextConfig.getTextStyle(
                                      size: 12, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: Colors.blueGrey,
        ),
        Expanded(
            child: ListView.builder(
          itemBuilder: createItem,
          itemCount: _list == null ? 0 : _list.length,
        )),
      ],
    );

    Container container = new Container(
      child: column,
    );

    Widget w = Scaffold(
      body: container,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _goEditPage(-1);
        },
        foregroundColor: Colors.red,
        child: Icon(
          Icons.edit,
          color: Colors.orangeAccent,
        ),
      ),
    );

    return w;
  }

  Widget createItem(BuildContext context, int index) {
    INoteItem item = _list[index];
    Column column = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          item.getTitle(),
          style: TextConfig.getTextStyle(
              size: TextConfig.CONTENT_TEXT_NORMAL_SIZE),
        ),
        SizedBox(
          height: 3,
        ),
        Text(
          StringUtils.getTimestampStr(item.getTime()),
          style:
              TextConfig.getTextStyle(size: TextConfig.CONTENT_TEXT_SMALL_SIZE),
        ),
      ],
    );

    Widget selectW = GestureDetector(
      onTap: () {
        itemSelectClick(item);
      },
      child: SizedBox(
        width: 50,
        child: Center(
          child: item.isSelected()
              ? Icon(
                  Icons.check_box,
                  size: 25,
                  color: Colors.orangeAccent,
                )
              : Icon(
                  Icons.check_box_outline_blank,
                  size: 25,
                  color: Colors.orangeAccent,
                ),
        ),
      ),
    );

    Row row = Row(
      children: <Widget>[
        SizedBox(
          width: 15,
        ),
        Expanded(child: column),
        Offstage(
          offstage: !item.isCouldEdit(),
          child: selectW,
        )
      ],
    );

    Column itemW = new Column(
      children: <Widget>[
        SizedBox(
          height: 60,
          child: row,
        ),
        SizedBox(
          height: 1,
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
            ),
            child: Container(color: Colors.black12),
          ),
        ),
      ],
    );

    GestureDetector gestureDetector = new GestureDetector(
      onTap: () {
        if (item.isCouldEdit()) {
          itemSelectClick(item);
        } else {
          _goEditPage(item.getId(), note: item.getData());
        }
      },
      child: itemW,
    );

    return gestureDetector;
  }

  void itemSelectClick(INoteItem item) {
    bool isCheck = item.isSelected();
    setState(() {
      item.setSelected(!isCheck);
    });
  }
}

class NoteItem implements INoteItem<NoteEntity> {
  bool isEditAble;
  bool isSelect;
  NoteEntity noteEntity;

  NoteItem(
      {this.isEditAble = false,
      this.isSelect = false,
      @required this.noteEntity});

  @override
  int getTime() {
    int time = DateTime.now().millisecondsSinceEpoch;
    time = noteEntity?.updateTime;
    return time;
  }

  @override
  String getTitle() {
    String title = "新建笔记";
    title = noteEntity?.title;
    return title;
  }

  @override
  bool isCouldEdit() {
    return isEditAble;
  }

  @override
  bool isSelected() {
    return isSelect;
  }

  @override
  void setSelected(bool isSelected) {
    this.isSelect = isSelected;
  }

  @override
  int getId() {
    if (noteEntity != null) {
      return noteEntity.id;
    }
    return -1;
  }

  @override
  NoteEntity getData() {
    return noteEntity;
  }

  @override
  void setEditAble(bool edit) {
    this.isEditAble = edit;
  }
}

abstract class INoteItem<T> {
  int getId();

  T getData();

  bool isCouldEdit();

  void setEditAble(bool edit);

  bool isSelected();

  void setSelected(bool isSelected);

  int getTime();

  String getTitle();
}
