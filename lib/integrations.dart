// Örnek: Google Takvim Entegrasyonu
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:task_manager/main.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleCalendarService {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  Future<void> addTaskToGoogleCalendar(Task task) async {
    final client = await _getAuthenticatedClient();
    if (client == null) return;

    final calendarApi = calendar.CalendarApi(client);

    // EventDateTime nesnelerini doğru şekilde oluştur
    final startDateTime = calendar.EventDateTime()
      ..dateTime = task.dueDate.toUtc()
      ..timeZone = 'UTC';

    final endDateTime = calendar.EventDateTime()
      ..dateTime = task.dueDate.add(const Duration(hours: 1)).toUtc()
      ..timeZone = 'UTC';

    final event = calendar.Event()
      ..summary = task.title
      ..description = task.description
      ..start = startDateTime
      ..end = endDateTime;

    await calendarApi.events.insert(event, 'primary');
    client.close();
  }

  Future<List<Task>> importTasksFromGoogleCalendar(
      DateTime start, DateTime end) async {
    final client = await _getAuthenticatedClient();
    if (client == null) return [];

    final calendarApi = calendar.CalendarApi(client);

    final events = await calendarApi.events.list(
      'primary',
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    final tasks = <Task>[];

    for (var event in events.items ?? []) {
      if (event.start?.dateTime != null) {
        tasks.add(Task(
          id: event.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: event.summary ?? 'Adsız Görev',
          description: event.description ?? '',
          dueDate: event.start!.dateTime!.toLocal(),
          priority: 'Medium',
          tags: [],
        ));
      }
    }

    client.close();
    return tasks;
  }

  Future<AutoRefreshingAuthClient?> _getAuthenticatedClient() async {
    // OAuth kimlik doğrulama mantığını burada uygulayın
    // Örnek uygulama için null dönüyoruz, gerçek uygulamada OAuth akışını tamamlayın
    return null;
  }
}
