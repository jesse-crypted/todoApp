import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/todo_models.dart';

class DatabaseHelper {
  DatabaseHelper.internal();

// create a singleton static instance with the private constructor
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  // store connection to the database
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  // getter to return databes if it already exists, and create a new one if it doesnt
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // create a method to initialize database
  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'todo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // then we create a method to create a new databsase
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE todos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      done INTEGER
    )
''');
  }

  // methods that interact with the database
  // 1. method that takes a Todo object and insert it into todos table
  Future<int> insertTodo(Todo todo) async {
    final Database db = await database;
    return await db.insert('todos', todo.toMap());
  }

  // 2. method that retrieves all items from the todos table and return it as a list
  Future<List<Todo>> getTodos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (index) {
      return Todo.fromMap(maps[index]);
    });
  }

// 3. method that takes a Todo object and update it in the todos table
  Future<int> updateTodo(Todo todo) async {
    final Database db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id= ?',
      whereArgs: [todo.id],
    );
  }

  // 4. method that takes in an id of a Todo object, and delete that todo in the todos table
  Future<int> deleteTodoById(int id) async {
    final Database db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
