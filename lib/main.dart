import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/views/admin_dashboard_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const WasselniAdminApp());
}

class WasselniAdminApp extends StatelessWidget {
  const WasselniAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wasselni Admin',
      theme: AppTheme.light,
      home: const AdminDashboardLayout(),
    );
  }
}
