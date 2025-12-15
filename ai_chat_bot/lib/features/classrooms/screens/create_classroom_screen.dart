import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/classroom_provider.dart';
import '../../../core/providers/organization_provider.dart';
import '../../../core/models/classroom.dart';

/// Screen for creating a new classroom
class CreateClassroomScreen extends StatefulWidget {
  const CreateClassroomScreen({super.key});

  @override
  State<CreateClassroomScreen> createState() => _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends State<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _academicYearController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _gradeLevelController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Classroom'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Organization Info
            Consumer<OrganizationProvider>(
              builder: (context, orgProvider, child) {
                if (orgProvider.selectedOrganization != null) {
                  return Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.business),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Organization',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  orgProvider.selectedOrganization!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),

            // Classroom Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Classroom Name *',
                hintText: 'e.g., Math 101, Science A',
                prefixIcon: Icon(Icons.class_),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Classroom name is required';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of the classroom',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Subject
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g., Mathematics, Physics',
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Grade Level
            TextFormField(
              controller: _gradeLevelController,
              decoration: const InputDecoration(
                labelText: 'Grade Level',
                hintText: 'e.g., Grade 10, Year 1',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Academic Year
            TextFormField(
              controller: _academicYearController,
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                hintText: 'e.g., 2024-2025',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _createClassroom,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Create Classroom',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final orgProvider = context.read<OrganizationProvider>();
    final request = CreateClassroomRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      organizationId: orgProvider.selectedOrganization?.id,
      subject: _subjectController.text.trim().isEmpty
          ? null
          : _subjectController.text.trim(),
      gradeLevel: _gradeLevelController.text.trim().isEmpty
          ? null
          : _gradeLevelController.text.trim(),
      academicYear: _academicYearController.text.trim().isEmpty
          ? null
          : _academicYearController.text.trim(),
    );

    final provider = context.read<ClassroomProvider>();
    final classroom = await provider.createClassroom(request);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (classroom != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Classroom "${classroom.name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to create classroom'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
