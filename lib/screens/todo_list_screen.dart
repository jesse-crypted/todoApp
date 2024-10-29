import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:glasstask/services/db_helper.dart';
import 'package:glasstask/model/todo_models.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _titleEditingController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Todo> _todos = [];

  // method that loads the todos when first initialized
  void initState() {
    super.initState();
    _loadTodos();
  }

  // a method that loads/refreshes the list of todos from the database
  Future<void> _loadTodos() async {
    List<Todo> todos = await _databaseHelper.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  // method that adds a new todo according to the user input in the global textcontrolleer
  Future<void> _addTodo() async {
    final String title = _titleEditingController.text.trim();
    if (title.isEmpty) return;

    final Todo todo = Todo(title: title, description: '', done: false);

    await _databaseHelper.insertTodo(todo);
    _titleEditingController.clear();
    await _loadTodos();
  }

  Future<void> _updateTodoDone(int id, bool done) async{
    final Todo todo = _todos.firstWhere((element) => element.id == id);
    todo.done = done;
    await _databaseHelper.updateTodo(todo);
    await _loadTodos();
  }

  Future<void> _deleteTodoById(int id)async{
    await _databaseHelper.deleteTodoById(id);
    await _loadTodos();

  }

  @override
  Widget build(BuildContext context) {
    String now = DateFormat("EEEE, MMMM dd").format(DateTime.now());
    return Scaffold(

      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.topRight,
        secondaryBegin: Alignment.bottomLeft,
        secondaryEnd: Alignment.bottomRight,
        primaryColors: [
          Colors.teal.shade50,
          Colors.teal.shade300,
          Colors.teal.shade600,
        ],
        secondaryColors: [
          Colors.teal.shade700,
          Colors.tealAccent,
          Colors.teal.shade100,
        ],
        child: SafeArea(
          child: Column(children: [
            //This will replce the appbar and display the date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child:  Text(
                    now,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white,),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            // This will be the full height list of all the todo items
            Expanded(
              child: _buildTodoList(),
            ),
            // This will be the input field at the bottom where you can add a new todo
            _buildAddTodoField(),
          ]),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final Todo todo = _todos[index];
          return _TodoCard(todo);
        });
  }

  Widget _TodoCard(Todo todo){
    return GestureDetector(
    onTap: (){
      _updateTodoDone(todo.id!, todo.done ? false : true);
    },
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY:8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Center(
                      child: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          shape:  ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0),),
                          ), onChanged: (bool? value) {
                            _updateTodoDone(todo.id!, value!);
                        }, value: todo.done,
                        ),
                      ),
                    ),
                    Expanded(child: Text(todo.title),
                    ),
                    IconButton(onPressed: (){_deleteTodoById(todo.id!);}, icon: const Icon(Icons.close),)
                  ],
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white54, Colors.white10],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTodoField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    controller: _titleEditingController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Add a new todo',
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        SizedBox(width: 12,),
        RawMaterialButton(
            constraints: BoxConstraints(minWidth: 54, minHeight: 54),
            onPressed: _addTodo,
        fillColor: Colors.teal,
          child: Icon(Icons.arrow_upward_rounded, color: Colors.white,),
          padding: EdgeInsets.all(12),
          shape: CircleBorder(),
        )
        ],
      ),
    );
  }
}
