import 'package:flutter/material.dart';
import 'package:nowly/core/widgets/app_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLayout(
        headerText: "Perfil",
        body: Center(child: Text("Perfil")),
      ),
    );
  }
}
