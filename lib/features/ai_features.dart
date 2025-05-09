// Örnek: Akıllı Görev Öneri Sistemi
import 'package:task_manager/main.dart';

class TaskRecommendationSystem {
  List<Task> _userTasks = [];
  Map<String, int> _userPreferences = {};

  void analyzeUserBehavior(List<Task> completedTasks) {
    _userTasks = completedTasks;

    // Kullanıcının tamamladığı görevlerin analizini yap
    for (var task in completedTasks) {
      // Etiketlere göre tercih analizi
      for (var tag in task.tags) {
        _userPreferences[tag] = (_userPreferences[tag] ?? 0) + 1;
      }

      // Önceliğe göre tercih analizi
      _userPreferences[task.priority] =
          (_userPreferences[task.priority] ?? 0) + 1;

      // Gün ve saat analizleri yapılabilir
    }
  }

  List<String> recommendTags(String taskTitle) {
    // Başlığa göre etiket önerisi
    final words = taskTitle.toLowerCase().split(' ');
    final Map<String, int> tagScores = {};

    // Başlıktaki kelimelere göre etiket puanlaması
    for (var tag in _userPreferences.keys) {
      if (tag == 'High' || tag == 'Medium' || tag == 'Low') continue;

      final tagWords = tag.toLowerCase().split(' ');
      for (var word in words) {
        if (tagWords.contains(word) || word.contains(tag.toLowerCase())) {
          tagScores[tag] = (tagScores[tag] ?? 0) + 3;
        }
      }

      // Kullanıcı tercihlerine göre puan ekle
      tagScores[tag] = (tagScores[tag] ?? 0) + (_userPreferences[tag] ?? 0);
    }

    // En yüksek puanlı 3 etiketi öner
    final sortedTags = tagScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(3).map((e) => e.key).toList();
  }

  String recommendPriority(String taskTitle, String description) {
    // Başlık ve açıklamaya göre öncelik önerisi
    final combinedText = (taskTitle + ' ' + description).toLowerCase();

    // Aciliyet belirten kelimeler
    final highPriorityKeywords = [
      'acil',
      'önemli',
      'hemen',
      'kritik',
      'son',
      'deadline'
    ];
    final mediumPriorityKeywords = ['gerekli', 'önem', 'yakında', 'bu hafta'];
    final lowPriorityKeywords = ['ileride', 'belki', 'düşük', 'zaman olursa'];

    int highScore = 0;
    int mediumScore = 0;
    int lowScore = 0;

    for (var keyword in highPriorityKeywords) {
      if (combinedText.contains(keyword)) highScore += 2;
    }

    for (var keyword in mediumPriorityKeywords) {
      if (combinedText.contains(keyword)) mediumScore += 2;
    }

    for (var keyword in lowPriorityKeywords) {
      if (combinedText.contains(keyword)) lowScore += 2;
    }

    // Kullanıcı tercihlerine göre puan ekle
    highScore += _userPreferences['High'] ?? 0;
    mediumScore += _userPreferences['Medium'] ?? 0;
    lowScore += _userPreferences['Low'] ?? 0;

    // En yüksek puanlı önceliği öner
    if (highScore >= mediumScore && highScore >= lowScore) {
      return 'High';
    } else if (mediumScore >= highScore && mediumScore >= lowScore) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  DateTime recommendDueDate(String taskTitle, String priority) {
    // Başlık ve önceliğe göre son tarih önerisi
    final now = DateTime.now();

    if (priority == 'High') {
      // Yüksek öncelikli görevler için 1-2 gün içinde
      return now.add(Duration(days: 1 + (now.weekday >= 5 ? 2 : 0)));
    } else if (priority == 'Medium') {
      // Orta öncelikli görevler için 3-5 gün içinde
      return now.add(Duration(days: 3 + (now.weekday >= 3 ? 2 : 0)));
    } else {
      // Düşük öncelikli görevler için 1-2 hafta içinde
      return now.add(Duration(days: 7 + (now.weekday >= 5 ? 2 : 0)));
    }
  }
}
