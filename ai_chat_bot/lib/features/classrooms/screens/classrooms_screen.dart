import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/classroom_provider.dart';
import '../../../core/providers/organization_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/models/classroom.dart';
import 'create_classroom_screen.dart';
import '../../chat/screens/chat_screen.dart';

/// Screen displaying list of classrooms
class ClassroomsScreen extends StatefulWidget {
  const ClassroomsScreen({super.key});

  @override
  State<ClassroomsScreen> createState() => _ClassroomsScreenState();
}

class _ClassroomsScreenState extends State<ClassroomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final orgProvider = context.read<OrganizationProvider>();
        final classroomProvider = context.read<ClassroomProvider>();
        
        // Load classrooms (will be empty if no organizations exist)
        await classroomProvider.loadClassrooms(
          organizationId: orgProvider.selectedOrganization?.id,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading classrooms: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classrooms'),
        actions: [
          Consumer<OrganizationProvider>(
            builder: (context, orgProvider, child) {
              if (orgProvider.selectedOrganization != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Chip(
                      avatar: const Icon(Icons.business, size: 16),
                      label: Text(
                        orgProvider.selectedOrganization!.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Organizations button
          IconButton(
            icon: const Icon(Icons.business),
            tooltip: 'Organizations',
            onPressed: () => Navigator.pushNamed(context, '/organizations'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final orgProvider = context.read<OrganizationProvider>();
              context.read<ClassroomProvider>().loadClassrooms(
                    organizationId: orgProvider.selectedOrganization?.id,
                  );
            },
          ),
          // Logout button
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => Text(
                        auth.currentUser?.email ?? 'Profile',
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
          ),
        ],
      ),
      body: Consumer<ClassroomProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.classrooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final orgProvider = context.read<OrganizationProvider>();
                      provider.loadClassrooms(
                        organizationId: orgProvider.selectedOrganization?.id,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.classrooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.class_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No classrooms yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Create your first classroom to get started'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreate(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Classroom'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              final orgProvider = context.read<OrganizationProvider>();
              return provider.loadClassrooms(
                organizationId: orgProvider.selectedOrganization?.id,
              );
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: provider.classrooms.length,
              itemBuilder: (context, index) {
                final classroom = provider.classrooms[index];
                return _ClassroomCard(
                  classroom: classroom,
                  isSelected: provider.selectedClassroom?.id == classroom.id,
                  onTap: () => _navigateToDetail(context, classroom),
                  onSelect: () => provider.selectClassroom(classroom),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('New Classroom'),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateClassroomScreen(),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Classroom classroom) async {
    // Set classroom context for chat
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setClassroomContext(classroom.id);
    
    // Navigate directly to chat screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
    
    // Clear classroom context when returning
    if (mounted) {
      chatProvider.clearClassroomContext();
    }
  }
}

class _ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  const _ClassroomCard({
    required this.classroom,
    required this.isSelected,
    required this.onTap,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and selection
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Radio<bool>(
                    value: true,
                    groupValue: isSelected,
                    onChanged: (_) => onSelect(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Classroom Name
              Text(
                classroom.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (classroom.subject != null) ...[
                const SizedBox(height: 4),
                Text(
                  classroom.subject!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              // Tags
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (classroom.gradeLevel != null)
                    _buildTag(
                      context,
                      classroom.gradeLevel!,
                      Icons.school,
                    ),
                  if (!classroom.isActive)
                    _buildTag(
                      context,
                      'Inactive',
                      Icons.cancel,
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color ?? Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
