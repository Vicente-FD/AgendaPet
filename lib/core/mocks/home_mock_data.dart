import 'package:flutter/material.dart';

class MockPet {
  const MockPet({
    required this.name,
    required this.pendingTasks,
    required this.species,
  });

  final String name;
  final int pendingTasks;
  final String species;
}

class MockReminder {
  const MockReminder({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.showAction = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool showAction;
}

abstract final class HomeMockData {
  static const String userName = 'María';

  static const MockPet activePet = MockPet(
    name: 'Carolina',
    pendingTasks: 2,
    species: 'Perro',
  );

  static const List<MockReminder> upcomingReminders = [
    MockReminder(
      title: 'Baño',
      subtitle: 'Mañana, martes 25 a las 16:00',
      icon: Icons.calendar_today_outlined,
      iconColor: Color(0xFF1E88E5),
    ),
    MockReminder(
      title: 'Vacuna Rabia',
      subtitle: 'Martes, 30 de abril',
      icon: Icons.vaccines_outlined,
      iconColor: Color(0xFF43A047),
      showAction: true,
    ),
  ];
}
