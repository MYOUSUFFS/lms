import 'package:flutter/foundation.dart';
import '../models/classroom.dart';
import '../services/classroom_service.dart';

/// Provider for classroom state management
class ClassroomProvider with ChangeNotifier {
  final ClassroomService _classroomService;

  List<Classroom> _classrooms = [];
  Classroom? _selectedClassroom;
  List<ClassroomMember> _members = [];
  bool _isLoading = false;
  String? _error;

  ClassroomProvider(this._classroomService);

  // Getters
  List<Classroom> get classrooms => _classrooms;
  Classroom? get selectedClassroom => _selectedClassroom;
  List<ClassroomMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set authentication token
  void setToken(String token) {
    _classroomService.setToken(token);
  }

  /// Load all classrooms
  Future<void> loadClassrooms({String? organizationId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classrooms = await _classroomService.listClassrooms(
        organizationId: organizationId,
      );

      // Auto-select first classroom if none selected
      if (_selectedClassroom == null && _classrooms.isNotEmpty) {
        _selectedClassroom = _classrooms.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new classroom
  Future<Classroom?> createClassroom(CreateClassroomRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classroom = await _classroomService.createClassroom(request);
      _classrooms.add(classroom);
      _selectedClassroom = classroom;
      _isLoading = false;
      notifyListeners();
      return classroom;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update classroom
  Future<bool> updateClassroom(
      String id, UpdateClassroomRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _classroomService.updateClassroom(id, request);
      final index = _classrooms.indexWhere((c) => c.id == id);
      if (index != -1) {
        _classrooms[index] = updated;
      }
      if (_selectedClassroom?.id == id) {
        _selectedClassroom = updated;
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

  /// Delete classroom
  Future<bool> deleteClassroom(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _classroomService.deleteClassroom(id);
      _classrooms.removeWhere((c) => c.id == id);
      if (_selectedClassroom?.id == id) {
        _selectedClassroom = _classrooms.isNotEmpty ? _classrooms.first : null;
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

  /// Select classroom
  void selectClassroom(Classroom classroom) {
    _selectedClassroom = classroom;
    notifyListeners();
  }

  /// Load members for selected classroom
  Future<void> loadMembers() async {
    if (_selectedClassroom == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _classroomService.listMembers(_selectedClassroom!.id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add member to classroom
  Future<bool> addMember(String userId, String role) async {
    if (_selectedClassroom == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final member = await _classroomService.addMember(
        _selectedClassroom!.id,
        userId,
        role,
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

  /// Remove member from classroom
  Future<bool> removeMember(String memberId) async {
    if (_selectedClassroom == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _classroomService.removeMember(_selectedClassroom!.id, memberId);
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

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
