import 'package:agenda_pet/core/mocks/tips_mock_data.dart';
import 'package:agenda_pet/shared/widgets/section_header.dart';
import 'package:agenda_pet/shared/widgets/tip_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tips inteligentes: consejos de cuidado curados según la mascota.
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Tips para tu mascota'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const TipCard(tip: TipsMockData.tipOfTheDay),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Consejos recomendados'),
          const SizedBox(height: 12),
          ...TipsMockData.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TipCard(tip: tip),
            ),
          ),
        ],
      ),
    );
  }
}
