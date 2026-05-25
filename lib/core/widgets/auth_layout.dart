import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_back_button.dart';
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
    this.headerText,
    this.headerBuilder,
    this.showBackButton = false,
    required this.body,
  });

  /// Simple text header (default styled)
  final String? headerText;

  /// Custom header builder (has priority over headerText)
  final WidgetBuilder? headerBuilder;

  /// Show backbutton to return to last stack page
  final bool showBackButton;

  /// Main content
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
          padding: context.paddingScreen.copyWith(bottom: 0, left: context.paddingLeft + 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 20.h
            ),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBackButton)
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    child: AppBackButton(),
                  )
                else
                  const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(context.paddingLeft + 32, 16, context.paddingRight + 32, context.paddingBottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 16 - context.paddingBottom),
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
            padding: context.paddingScreen.copyWith(left: context.paddingLeft + 16, right: 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        if (showBackButton)... [
                          const AppBackButton(),
                          const SizedBox(height: 32),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _buildHeader(context),
                        ),
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
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(32, 16, context.paddingRight + 32, context.paddingBottom),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 16 - context.paddingBottom),
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

  /// Centralized header resolution logic
  Widget _buildHeader(BuildContext context) {
    final Widget resolvedHeader;

    if (headerBuilder != null) {
      resolvedHeader = headerBuilder!(context);
    } else if (headerText != null) {
      resolvedHeader = Text(
        headerText!,
        style: context.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: "Ultra",
          color: context.colorScheme.onPrimary,
        ),
      );
    } else {
      resolvedHeader = const SizedBox.shrink();
    }

    return resolvedHeader;
  }
}
