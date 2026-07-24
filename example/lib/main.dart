import 'package:flutter/material.dart';

void main() {
  runApp(const ReleaseManagerExampleApp());
}

class ReleaseManagerExampleApp extends StatelessWidget {
  const ReleaseManagerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Release Manager Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Release Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Application Name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Release Manager Example'),
            SizedBox(height: 20),
            Text(
              'Current Version:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1.0.0+1'),
            SizedBox(height: 20),
            Text(
              'Current Environment:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('DEV'),
            SizedBox(height: 20),
            Text(
              'Current Build Number:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('001'),
          ],
        ),
      ),
    );
  }
}
