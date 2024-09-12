import 'package:sqflite/sqflite.dart';
import 'dart:core';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'databasemodel.dart';

class Databasehelper {
  Databasehelper._privateConstructor();
  static final Databasehelper instance = Databasehelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future <Database> _initDatabase() async{
    Directory appdir = await getApplicationDocumentsDirectory();
    String path = join(appdir.path, 'checklist.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  Future _onCreate(Database db, int version) async{
    await db.execute(
      'CREATE TABLE checklist(id INTEGER PRIMARY KEY, name TEXT, date TEXT, remind INTEGER)',
    ); 
    await db.execute(
      'CREATE TABLE content(id INTEGER PRIMARY KEY, templateid INTEGER, tabname TEXT)',
    ); 
    await db.execute(
      'CREATE TABLE field(id INTEGER PRIMARY KEY, templateid INTEGER, contentid INTEGER, field TEXT, checkbox TEXT, checklist TEXT, description TEXT)',
    ); 
    await db.execute(
      'CREATE TABLE imagepath(id INTEGER PRIMARY KEY, templateid INTEGER, contentid INTERGER, fieldid INTEGER, path TEXT)',
    );
    await db.execute(
      'CREATE TABLE specialfield(id INTEGER PRIMARY KEY, templateid INTEGER, contentid INTERGER, fieldid INTEGER, value TEXT, selection TEXT)',
    );
  }
  
  Future<List<Checklist>> getChecklist() async{
    Database db = await instance.database;
    var checklists = await db.query('checklist', orderBy: 'id');
    print(checklists);
    List<Checklist> checklistList = checklists.isNotEmpty ? checklists.map((n) => Checklist.fromMap(n)).toList():[];
    return checklistList;
  }

  Future<int> addChecklist(Checklist checklist) async{
    Database db = await instance.database;
    return await db.insert('checklist', checklist.toMap());
  }

  Future<int> removeChecklist(int id) async{
    Database db = await instance.database;
    return await db.delete('checklist', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countChecklist() async {
    Database db = await instance.database;
    var result = await db.query('checklist', orderBy: 'id');
    int count = result.length;
    return count;
  }  

  Future<int> updateChecklist(Checklist checklist) async{
    Database db = await instance.database;
    return await db.update('checklist', checklist.toMap(), where: 'id = ?', whereArgs: [checklist.id]).then((value){return value;});
  }

  Future<List<Content>> getContent() async{
    Database db = await instance.database;
    var content = await db.query('content', orderBy: 'id');
    print(content);
    List<Content> contentlist = content.isNotEmpty ? content.map((n) => Content.fromMap(n)).toList():[];
    return contentlist;
  }

  Future<int> addContent(Content content) async{
    Database db = await instance.database;
    return await db.insert('content', content.toMap());
  }

  Future<int> removeContent(int id) async{
    Database db = await instance.database;
    return await db.delete('content', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countContent() async {
    Database db = await instance.database;
    var result = await db.query('content');
    int count = result.length;
    return count;
  }

  Future<int> updateContent(Content content) async{
    Database db = await instance.database;
    return await db.update('content', content.toMap(), where: 'id = ?', whereArgs: [content.id]).then((value){return value;});
  }

  Future<List<Field>> getField() async{
    Database db = await instance.database;
    var field = await db.query('field', orderBy: 'id');
    print(field);
    List<Field> fieldlist = field.isNotEmpty ? field.map((n) => Field.fromMap(n)).toList():[];
    return fieldlist;
  }

  Future<int> addField(Field field) async{
    Database db = await instance.database;
    return await db.insert('field', field.toMap());
  }

  Future<int> removeField(int id) async{
    Database db = await instance.database;
    return await db.delete('field', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countField() async {
    Database db = await instance.database;
    var result = await db.query('field');
    int count = result.length;
    return count;
  }

  Future<int> updateField(Field field) async{
    Database db = await instance.database;
    return await db.update('field', field.toMap(), where: 'id = ?', whereArgs: [field.id]).then((value){return value;});
  }

  Future<List<Imagepath>> getPath() async{
    Database db = await instance.database;
    var path = await db.query('imagepath', orderBy: 'id');
    print(path);
    List<Imagepath> pathlist = path.isNotEmpty ? path.map((n) => Imagepath.fromMap(n)).toList():[];
    return pathlist;
  }

  Future<int> addPath(Imagepath path) async{
    Database db = await instance.database;
    return await db.insert('imagepath', path.toMap());
  }

  Future<int> removePath(int id) async{
    Database db = await instance.database;
    return await db.delete('imagepath', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePath(Imagepath path) async{
    Database db = await instance.database;
    return await db.update('imagepath', path.toMap(), where: 'id = ?', whereArgs: [path.id]).then((value){return value;});
  }

  Future<int> countPath() async {
    Database db = await instance.database;
    var result = await db.query('imagepath');
    int count = result.length;
    return count;
  }

  Future<List<Specialfield>> getValue() async{
    Database db = await instance.database;
    var path = await db.query('specialfield', orderBy: 'id');
    print(path);
    List<Specialfield> pathlist = path.isNotEmpty ? path.map((n) => Specialfield.fromMap(n)).toList():[];
    return pathlist;
  }

  Future<int> addValue(Specialfield value) async{
    Database db = await instance.database;
    return await db.insert('specialfield', value.toMap());
  }

  Future<int> removeValue(int id) async{
    Database db = await instance.database;
    return await db.delete('specialfield', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateValue(Specialfield value) async{
    Database db = await instance.database;
    return await db.update('specialfield', value.toMap(), where: 'id = ?', whereArgs: [value.id]).then((value){return value;});
  }

  Future<int> countValue() async {
    Database db = await instance.database;
    var result = await db.query('specialfield');
    int count = result.length;
    return count;
  }

}