import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/organization_provider.dart';
import '../../../core/models/organization.dart';

/// Screen showing organization details and member management
class OrganizationDetailScreen extends StatefulWidget {
  final Organization organization;

  const OrganizationDetailScreen({
    super.key,
    required this.organization,
  });

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrganizationProvider>();
      provider.selectOrganization(widget.organization);
      provider.loadMembers();
      provider.loadInvitations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Details'),
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.mail), text: 'Invitations'),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog();
              } else if (value == 'delete') {
                _showDeleteDialog();
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildMembersTab(),
          _buildInvitationsTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Organization Information',
            [
              _buildInfoRow('Name', widget.organization.name),
              if (widget.organization.description != null)
                _buildInfoRow('Description', widget.organization.description!),
              _buildInfoRow('Type', _getTypeLabel(widget.organization.type)),
              _buildInfoRow(
                'Status',
                widget.organization.isActive ? 'Active' : 'Inactive',
                valueColor:
                    widget.organization.isActive ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Contact Information',
            [
              if (widget.organization.website != null)
                _buildInfoRow('Website', widget.organization.website!),
              if (widget.organization.contactEmail != null)
                _buildInfoRow('Email', widget.organization.contactEmail!),
              if (widget.organization.contactPhone != null)
                _buildInfoRow('Phone', widget.organization.contactPhone!),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'System Information',
            [
              _buildInfoRow(
                'Created',
                _formatDate(widget.organization.createdAt),
              ),
              _buildInfoRow(
                'Last Updated',
                _formatDate(widget.organization.updatedAt),
              ),
              _buildInfoRow('Organization ID', widget.organization.id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return Consumer<OrganizationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No members yet'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showInviteMemberDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Invite Member'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${provider.members.length} member(s)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showInviteMemberDialog(),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Invite'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.loadMembers(),
                child: ListView.builder(
                  itemCount: provider.members.length,
                  itemBuilder: (context, index) {
                    final member = provider.members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (member.userName ?? 'U')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(member.userName ?? 'Unknown User'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (member.userEmail != null) Text(member.userEmail!),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildRoleChip(member.role),
                              const SizedBox(width: 8),
                              if (!member.isActive)
                                Chip(
                                  label: const Text('Inactive'),
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.person_remove, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'remove') {
                            _showRemoveMemberDialog(member.id, member.userName);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvitationsTab() {
    return Consumer<OrganizationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.invitations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.invitations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No pending invitations'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadInvitations(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.invitations.length,
            itemBuilder: (context, index) {
              final invitation = provider.invitations[index];
              final isExpired = invitation.expiresAt.isBefore(DateTime.now());
              final isPending = invitation.status == 'pending';

              return Card(
                child: ListTile(
                  leading: Icon(
                    isPending ? Icons.mail : Icons.check_circle,
                    color: isExpired
                        ? Colors.grey
                        : isPending
                            ? Colors.orange
                            : Colors.green,
                  ),
                  title: Text(invitation.email),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildRoleChip(invitation.role),
                      const SizedBox(height: 4),
                      Text(
                        isExpired
                            ? 'Expired'
                            : 'Expires: ${_formatDate(invitation.expiresAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isExpired ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: isPending && !isExpired
                      ? IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyInvitationToken(invitation.id),
                          tooltip: 'Copy invitation token',
                        )
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Chip(
      label: Text(_formatRole(role)),
      backgroundColor: _getRoleColor(role).withOpacity(0.1),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _getRoleColor(role),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'school_admin':
        return Colors.purple;
      case 'sub_admin':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'student':
        return Colors.orange;
      case 'parent':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatRole(String role) {
    return role
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'school':
        return 'School';
      case 'university':
        return 'University';
      case 'training_center':
        return 'Training Center';
      case 'corporate':
        return 'Corporate';
      default:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog() {
    // TODO: Implement edit organization dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organization'),
        content: Text(
          'Are you sure you want to delete "${widget.organization.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<OrganizationProvider>();
              final success =
                  await provider.deleteOrganization(widget.organization.id);
              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Organization deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Failed to delete'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    final emailController = TextEditingController();
    String selectedRole = 'student';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'user@example.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'sub_admin', child: Text('Sub Admin')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                  DropdownMenuItem(value: 'guest', child: Text('Guest')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.trim().isEmpty) return;

                Navigator.pop(context);
                final provider = context.read<OrganizationProvider>();
                final success = await provider.createInvitation(
                  CreateInvitationRequest(
                    email: emailController.text.trim(),
                    role: selectedRole,
                  ),
                );

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invitation sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(provider.error ?? 'Failed to send invitation'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send Invitation'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveMemberDialog(String memberId, String? userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${userName ?? "this member"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<OrganizationProvider>();
              final success = await provider.removeMember(memberId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Member removed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(provider.error ?? 'Failed to remove member'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _copyInvitationToken(String token) {
    Clipboard.setData(ClipboardData(text: token));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation token copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
