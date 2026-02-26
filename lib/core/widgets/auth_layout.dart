import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:sizer/sizer.dart';

/// Responsive layout for authentication screens (login, signup, etc.).
///
/// In **portrait**: header on primary background at the top + body with
/// rounded corners on the surface below.
///
/// In **landscape**: two columns — header on the left (1/4) and body on
/// the right (3/4) with a rounded top-left corner.
///
/// ```dart
/// AuthLayout(
///   header: Text('Hello\nSign in to your account'),
///   body: Column(children: [...]),
/// )
/// ```
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.header,
    required this.body,
  });

  /// Widget displayed in the highlight area (primary background).
  final Widget header;

  /// Widget with the main content (form, buttons, etc.).
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Device.orientation == Orientation.portrait
              ? _buildPortrait(context)
              : _buildLandscape(context);
        },
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              header,
              SizedBox(height: 60 - context.paddingBottom),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            padding: context.paddingScreen,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: body,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: context.paddingScreen,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        header,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.only(
              top: context.paddingTop,
            ),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                ),
              ),
              padding: EdgeInsets.fromLTRB(36, 16, context.paddingRight + 36, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: body,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
