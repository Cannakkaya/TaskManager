// Örnek: Rozet ve Seviye Sistemi
class UserAchievements {
  int taskPoints = 0;
  int level = 1;
  List<Badge> earnedBadges = [];

  void addPoints(int points) {
    taskPoints += points;
    _checkLevelUp();
    _checkBadges();
  }

  void _checkLevelUp() {
    // Her seviye için gereken puan: seviye * 100
    final nextLevelPoints = level * 100;

    if (taskPoints >= nextLevelPoints) {
      level++;
      // Seviye atlama bildirimi göster
    }
  }

  void _checkBadges() {
    // Tamamlanan görev sayısına göre rozetler
    if (taskPoints >= 100 && !_hasBadge('Başlangıç')) {
      earnedBadges.add(Badge(
        id: 'beginner',
        name: 'Başlangıç',
        description: '100 puan topladın!',
        iconPath: 'assets/badges/beginner.png',
      ));
    }

    if (taskPoints >= 500 && !_hasBadge('Çalışkan')) {
      earnedBadges.add(Badge(
        id: 'hardworker',
        name: 'Çalışkan',
        description: '500 puan topladın!',
        iconPath: 'assets/badges/hardworker.png',
      ));
    }

    if (taskPoints >= 1000 && !_hasBadge('Uzman')) {
      earnedBadges.add(Badge(
        id: 'expert',
        name: 'Uzman',
        description: '1000 puan topladın!',
        iconPath: 'assets/badges/expert.png',
      ));
    }

    // Diğer rozetler...
  }

  bool _hasBadge(String badgeName) {
    return earnedBadges.any((badge) => badge.name == badgeName);
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
  });
}
