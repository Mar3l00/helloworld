import 'package:flutter/material.dart';

void main() {
  runApp(const TaskSchedulerApp());
}

class TaskSchedulerApp extends StatefulWidget {
  const TaskSchedulerApp({super.key});

  @override
  State<TaskSchedulerApp> createState() => _TaskSchedulerAppState();
}

class _TaskSchedulerAppState extends State<TaskSchedulerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agendador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: HomeScreen(
        toggleTheme: _toggleTheme,
        currentMode: _themeMode,
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.currentMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TaskListScreen(
        toggleTheme: widget.toggleTheme,
        currentMode: widget.currentMode,
      ),
      ProfileScreen(
        toggleTheme: widget.toggleTheme,
        currentMode: widget.currentMode,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentMode;

  const TaskListScreen({
    super.key,
    required this.toggleTheme,
    required this.currentMode,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Reunião de Projeto',
      description: 'Discutir os novos requisitos com a equipe.',
      date: DateTime.now().add(const Duration(hours: 2)),
    ),
    Task(
      id: '2',
      title: 'Academia',
      description: 'Treino de pernas e cardio.',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _addTask() {
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nova Tarefa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Selecionar Dia'),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          setState(() {
                            _tasks.add(
                              Task(
                                id: DateTime.now().toString(),
                                title: _titleController.text,
                                description: _descController.text,
                                date: selectedDate,
                              ),
                            );
                          });
                          _titleController.clear();
                          _descController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Adicionar Tarefa'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _removeTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarefa removida'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.currentMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma tarefa agendada!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _removeTask(task.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            task.isCompleted = value!;
                          });
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.description),
                          const SizedBox(height: 4),
                          Text(
                            '${task.date.day}/${task.date.month}/${task.date.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeTask(task.id),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentMode;

  const ProfileScreen({
    super.key,
    required this.toggleTheme,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              currentMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text(
              'Usuário',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'usuario@email.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configurações'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notificações'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Ajuda & Suporte'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}