// Örnek: Görev Paylaşımı
class SharedTask {
  String taskId;
  String ownerId;
  List<String> sharedWithUserIds;
  Map<String, String> userPermissions; // 'read', 'edit', 'admin'

  SharedTask({
    required this.taskId,
    required this.ownerId,
    required this.sharedWithUserIds,
    required this.userPermissions,
  });

  // toJson ve fromJson metodları...
}

// Görev paylaşım servisi...
class TaskSharingService {
  Future<void> shareTaskWithUser(
      String taskId, String userId, String permission) async {
    // Görev paylaşım mantığı...
  }

  Future<List<SharedTask>> getTasksSharedWithMe() async {
    // Benimle paylaşılan görevleri getir...
    return [];
  }
}
