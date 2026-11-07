import 'package:flutter/material.dart';
import 'package:wasselni_admin/core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasselni Admin',
     theme: AppTheme.light,
     
    );
  }
}

