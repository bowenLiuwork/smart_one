import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableNoteBook = 'note_book';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnCreateTime = 'createTime';
final String columnUpdateTime = 'updateTime';
final String columnContent = 'content';
final String columnAttrFile = 'attrFile';

class NoteBookDBHelper {
  //单例 --------
  factory NoteBookDBHelper() => _getInstance();

  static NoteBookDBHelper get instance => _getInstance();

  static NoteBookDBHelper _instance;

  NoteBookDBHelper._internal() {
    // 初始化
    _noteProvider = new NoteProvider();
  }

  static NoteBookDBHelper _getInstance() {
    if (_instance == null) {
      _instance = new NoteBookDBHelper._internal();
    }
    return _instance;
  }

//-------------------

  NoteProvider _noteProvider;

  Future open() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'smart_one.db');
    await _noteProvider.open(path);
  }

  void close() async {
    await _noteProvider.close();
  }

  NoteProvider getDBProvider() {
    return _noteProvider;
  }
}

class NoteProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableNoteBook ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnContent text,
  $columnCreateTime integer,
  $columnUpdateTime integer,
  $columnAttrFile text)
''');
    });
  }

  Future close() {
    db.close();
  }

  Future<NoteEntity> insert(NoteEntity note) async {
    note.id = await db.insert(tableNoteBook, note.toMap());
    return note;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableNoteBook, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(NoteEntity note) async {
    return await db.update(tableNoteBook, note.toMap(),
        where: '$columnId = ?', whereArgs: [note.id]);
  }

  Future<NoteEntity> getNoteById(int id) async {
    List<Map> maps = await db.query(tableNoteBook,
        columns: [
          columnId,
          columnTitle,
          columnContent,
          columnCreateTime,
          columnUpdateTime,
          columnAttrFile
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return NoteEntity.fromMap(maps.first);
    }
    return null;
  }

  Future<List<NoteEntity>> getNoteByTitle(String title) async {
    List<Map> maps = await db.query(tableNoteBook,
        columns: [
          columnId,
          columnTitle,
          columnContent,
          columnCreateTime,
          columnUpdateTime,
          columnAttrFile
        ],
        where: '$columnTitle like %$title%');
    if (maps.length > 0) {
      return maps.map((itemMap) => NoteEntity.fromMap(itemMap)).toList();
    }
    return null;
  }

  Future<List<NoteEntity>> getNotesAll() async {
    List<Map> maps = await db.query(
      tableNoteBook,
      columns: [
        columnId,
        columnTitle,
        columnContent,
        columnCreateTime,
        columnUpdateTime,
        columnAttrFile
      ],
    );
    if (maps.length > 0) {
      List<NoteEntity> list =
          maps.map((itemMap) => NoteEntity.fromMap(itemMap)).toList();
      return list;
    }

    return null;
  }
}

class NoteEntity {
  int id;
  String title;
  String content;
  int createTime;
  int updateTime;
  List<String> attrFileJson;

  NoteEntity(
      {this.id,
      this.title,
      this.content,
      this.createTime,
      this.updateTime,
      this.attrFileJson});

  String _toAttrString() {
    String text = '';
    if (attrFileJson != null) {
      for (int i = 0; i < attrFileJson.length; i++) {
        String item = attrFileJson[i];
        text = text + '''"$item"''';
        if (i < attrFileJson.length - 1) {
          text = text + ',';
        }
      }
    }
    if (text.isNotEmpty) {
      text = '[' + text + ']';
    }
    print('attrs == $text');
    return text;
  }

  List<String> _toAttrList(String arrJson) {
    if (arrJson.isNotEmpty) {
      List responseJson = json.decode(arrJson);
      List<String> list = responseJson.map((m) => m.toString()).toList();
      return list;
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnContent: content,
      columnAttrFile: _toAttrString(),
      columnCreateTime: createTime,
      columnUpdateTime: updateTime,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  NoteEntity.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    content = map[columnContent];
    createTime = map[columnCreateTime];
    updateTime = map[columnUpdateTime];
    attrFileJson = _toAttrList(map[columnAttrFile]);
  }
}
