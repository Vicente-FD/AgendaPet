import 'package:agenda_pet/core/mocks/care_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/shared/widgets/category_screen_layout.dart';
import 'package:flutter/material.dart';

/// Listado de certificados y documentos de la mascota (vacunas, carnet, etc.).
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreenLayout(
      title: 'Certificados',
      subtitle: 'Documentos, carnets y certificados escaneados',
      icon: Icons.folder_special_outlined,
      color: AppColors.certificates,
      items: CareMockData.certificateItems,
      addButtonLabel: 'Agregar certificado',
      onAddPressed: () => context.goAddCertificate(),
    );
  }
}
