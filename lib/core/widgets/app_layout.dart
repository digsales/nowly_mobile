import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_back_button.dart';

/// Page layout for authenticated screens.
///
/// Has a primary-colored collapsible header and a surface-colored body with
/// rounded top corners. The header hides on scroll-down and floats back into
/// view on scroll-up from any position.
///
/// ```dart
/// AppLayout(
///   headerText: 'Início',
///   body: Column(children: [...]),
/// )
/// ```
class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    this.headerText,
    this.headerBuilder,
    this.showBackButton = false,
    required this.body,
    this.headerExpandedHeight = 96.0,
  });

  /// Simple text header (styled with Ultra font)
  final String? headerText;

  /// Custom header builder (takes priority over headerText)
  final WidgetBuilder? headerBuilder;

  /// Show back button to return to previous route
  final bool showBackButton;

  /// Main content
  final Widget body;

  /// Height of the header content area (excluding top padding and back button)
  final double headerExpandedHeight;

  @override
  Widget build(BuildContext context) {
    final paddingTop = context.paddingTop;
    final backButtonHeight = showBackButton ? 52.0 : 0.0;
    final totalHeaderHeight =
        paddingTop + backButtonHeight + headerExpandedHeight + 24.0;

    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            floating: true,
            delegate: _AppHeaderDelegate(
              maxExtent: totalHeaderHeight,
              showBackButton: showBackButton,
              header: _buildHeader(context),
            ),
          ),
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height - paddingTop,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (headerBuilder != null) return headerBuilder!(context);
    if (headerText != null) {
      return Text(
        headerText!,
        style: context.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: 'Ultra',
          color: context.colorScheme.onPrimary,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _AppHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _AppHeaderDelegate({
    required this.maxExtent,
    required this.showBackButton,
    required this.header,
  });

  @override
  final double maxExtent;
  final bool showBackButton;
  final Widget header;

  @override
  double get minExtent => 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final opacity = (1.0 - shrinkOffset / maxExtent).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        color: context.colorScheme.primary,
        padding: EdgeInsets.fromLTRB(
          context.paddingLeft + 32,
          context.paddingTop + 8,
          context.paddingRight + 32,
          24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBackButton) ...[
              const AppBackButton(),
              const SizedBox(height: 8),
            ],
            header,
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_AppHeaderDelegate old) =>
      maxExtent != old.maxExtent ||
      showBackButton != old.showBackButton ||
      header != old.header;
}
