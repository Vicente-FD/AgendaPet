import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Avisos de recordatorios programados en el propio teléfono.
///
/// No necesitan servidor: se agendan al crear el recordatorio y se cancelan
/// al completarlo o borrarlo. En web no hay soporte, así que todo se ignora
/// sin romper la app.
abstract final class LocalNotifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _listo = false;

  static const _canal = AndroidNotificationChannel(
    'recordatorios',
    'Recordatorios',
    description: 'Avisos de vacunas, medicinas y cuidados de tus mascotas.',
    importance: Importance.high,
  );

  static bool get _disponible => !kIsWeb;

  /// Se llama una vez al arrancar la app.
  static Future<void> init() async {
    if (!_disponible || _listo) return;
    try {
      tzdata.initializeTimeZones();
      final zona = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zona.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_canal);

      _listo = true;
    } catch (e) {
      debugPrint('No se pudieron inicializar las notificaciones: $e');
    }
  }

  /// Pide permiso para notificar. En Android 13+ y en iOS es obligatorio.
  static Future<bool> pedirPermiso() async {
    if (!_disponible) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
      return false;
    } catch (e) {
      debugPrint('No se pudo pedir permiso de notificaciones: $e');
      return false;
    }
  }

  /// Programa el aviso de un recordatorio. Si la fecha ya pasó, no hace nada.
  static Future<void> programar({
    required String id,
    required String titulo,
    required String cuerpo,
    required DateTime cuando,
  }) async {
    if (!_disponible) return;
    await init();
    if (!_listo) return;
    if (cuando.isBefore(DateTime.now())) return;

    try {
      await _plugin.zonedSchedule(
        id: idNumerico(id),
        title: titulo,
        body: cuerpo,
        scheduledDate: tz.TZDateTime.from(cuando, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _canal.id,
            _canal.name,
            channelDescription: _canal.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // Inexacto: no requiere el permiso de alarmas exactas de Android 12+
        // y para un recordatorio de cuidado la precisión al minuto no importa.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('No se pudo programar la notificación: $e');
    }
  }

  static Future<void> cancelar(String id) async {
    if (!_disponible) return;
    try {
      await _plugin.cancel(id: idNumerico(id));
    } catch (e) {
      debugPrint('No se pudo cancelar la notificación: $e');
    }
  }

  /// El plugin identifica las notificaciones con enteros de 32 bits y los
  /// recordatorios usan ids de texto, así que se convierten de forma estable.
  static int idNumerico(String id) => id.hashCode & 0x7fffffff;
}
