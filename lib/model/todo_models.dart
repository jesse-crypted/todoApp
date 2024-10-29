class Todo {
  int? id;
  String title;
  String description;
  bool done;

  Todo({
    this.id,
    this.title = "",
    this.description = "",
    this.done = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'done': done ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      done: map['done'] == 1,
    );
  }
}
