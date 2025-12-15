import 'package:flutter/foundation.dart';
import '../models/organization.dart';
import '../services/organization_service.dart';

/// Provider for organization state management
class OrganizationProvider with ChangeNotifier {
  final OrganizationService _organizationService;

  List<Organization> _organizations = [];
  Organization? _selectedOrganization;
  List<OrganizationMember> _members = [];
  List<Invitation> _invitations = [];
  bool _isLoading = false;
  String? _error;

  OrganizationProvider(this._organizationService);

  // Getters
  List<Organization> get organizations => _organizations;
  Organization? get selectedOrganization => _selectedOrganization;
  List<OrganizationMember> get members => _members;
  List<Invitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set authentication token
  void setToken(String token) {
    _organizationService.setToken(token);
  }

  /// Load all organizations
  Future<void> loadOrganizations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organizations = await _organizationService.listOrganizations();

      // Auto-select first organization if none selected
      if (_selectedOrganization == null && _organizations.isNotEmpty) {
        _selectedOrganization = _organizations.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new organization
  Future<Organization?> createOrganization(
      CreateOrganizationRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final organization =
          await _organizationService.createOrganization(request);
      _organizations.add(organization);
      _selectedOrganization = organization;
      _isLoading = false;
      notifyListeners();
      return organization;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update organization
  Future<bool> updateOrganization(
      String id, UpdateOrganizationRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated =
          await _organizationService.updateOrganization(id, request);
      final index = _organizations.indexWhere((o) => o.id == id);
      if (index != -1) {
        _organizations[index] = updated;
      }
      if (_selectedOrganization?.id == id) {
        _selectedOrganization = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete organization
  Future<bool> deleteOrganization(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _organizationService.deleteOrganization(id);
      _organizations.removeWhere((o) => o.id == id);
      if (_selectedOrganization?.id == id) {
        _selectedOrganization =
            _organizations.isNotEmpty ? _organizations.first : null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select organization
  void selectOrganization(Organization organization) {
    _selectedOrganization = organization;
    notifyListeners();
  }

  /// Load members for selected organization
  Future<void> loadMembers() async {
    if (_selectedOrganization == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members =
          await _organizationService.listMembers(_selectedOrganization!.id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add member to organization
  Future<bool> addMember(AddMemberRequest request) async {
    if (_selectedOrganization == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final member = await _organizationService.addMember(
        _selectedOrganization!.id,
        request,
      );
      _members.add(member);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove member from organization
  Future<bool> removeMember(String memberId) async {
    if (_selectedOrganization == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _organizationService.removeMember(
          _selectedOrganization!.id, memberId);
      _members.removeWhere((m) => m.id == memberId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load invitations for selected organization
  Future<void> loadInvitations() async {
    if (_selectedOrganization == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _invitations =
          await _organizationService.listInvitations(_selectedOrganization!.id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create invitation
  Future<bool> createInvitation(CreateInvitationRequest request) async {
    if (_selectedOrganization == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final invitation = await _organizationService.createInvitation(
        _selectedOrganization!.id,
        request,
      );
      _invitations.add(invitation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Accept invitation
  Future<bool> acceptInvitation(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _organizationService.acceptInvitation(token);
      await loadOrganizations(); // Reload organizations
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
