import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'features/contacts/presentation/cubit/contacts_provider.dart';
import 'features/contacts/presentation/ui/contacts_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await startServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Contacts'),
        ),
        // Temporary: the list is mounted directly until routing is in place.
        body: const ContactsProvider(child: ContactsList()),
      ),
    );
  }
}
