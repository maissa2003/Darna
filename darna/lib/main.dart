import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'core/constants/box_names.dart';
import 'core/services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: HiveTestPage());
}

class HiveTestPage extends StatefulWidget {
  const HiveTestPage({super.key});

  @override
  State<HiveTestPage> createState() => _HiveTestPageState();
}

class _HiveTestPageState extends State<HiveTestPage> {
  final box = Hive.box(BoxNames.session);
  int memoryCount = 0;
  String error = '';

  int get savedCount => box.get('counter', defaultValue: 0) as int;

  Future<void> _increment() async {
    try {
      await box.put('counter', savedCount + 1);
      error = '';
    } catch (e) {
      error = e.toString();
    }
    setState(() => memoryCount++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Hive test')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Memory counter: $memoryCount',
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              Text('Saved (Hive) counter: $savedCount',
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _increment,
          child: const Icon(Icons.add),
        ),
      );
}