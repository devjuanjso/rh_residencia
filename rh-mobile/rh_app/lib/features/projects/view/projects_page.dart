import 'package:flutter/material.dart';

class ProjectsPage extends StatelessWidget {
  ProjectsPage({super.key});

  final TextEditingController projectNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: projectNameController,
              decoration: const InputDecoration(
                hintText: 'Enter project name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
