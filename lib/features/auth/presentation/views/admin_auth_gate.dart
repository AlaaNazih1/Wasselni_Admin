import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/admin_auth_controller.dart';
import 'admin_login_view.dart';
import '../../../dashboard/presentation/views/admin_dashboard_layout.dart';

class AdminAuthGate extends ConsumerWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stackTrace) => const AdminLoginView(),

      data: (user) {
        if (user == null) {
          return const AdminLoginView();
        }

        return FutureBuilder<bool>(
          future: ref.read(adminAuthRepositoryProvider).isAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data != true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(adminAuthRepositoryProvider).signOut();
              });

              return const AdminLoginView();
            }

            return const AdminDashboardLayout();
          },
        );
      },
    );
  }
}
