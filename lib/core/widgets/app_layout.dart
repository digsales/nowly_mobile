import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_back_button.dart';
import 'package:sizer/sizer.dart';

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
  });

  /// Simple text header (styled with Ultra font)
  final String? headerText;

  /// Custom header builder (takes priority over headerText)
  final WidgetBuilder? headerBuilder;

  /// Show back button to return to previous route
  final bool showBackButton;

  /// Main content
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final backButtonHeight = showBackButton ? kToolbarHeight : 0.0;
    final totalHeaderHeight = context.paddingTop + backButtonHeight + 20.h;

    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: _AppHeaderDelegate(
              minExtent: context.paddingTop,
              maxExtent: totalHeaderHeight,
              showBackButton: showBackButton,
              header: _buildHeader(context),
            ),
          ),
        ],
        body: Padding(
          padding: EdgeInsets.only(top: context.paddingTop),
          child: Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 16,
                left: context.paddingLeft + 32,
                right: context.paddingRight + 32,
                bottom: context.paddingBottom + 16,
              ),
              child: body,
            ),
          ),
        ),
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
    required this.minExtent,
    required this.maxExtent,
    required this.showBackButton,
    required this.header,
  });

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final bool showBackButton;
  final Widget header;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
        child: Transform.translate(
          offset: Offset(0, -shrinkOffset),
          child: Padding(
            padding: EdgeInsets.only(
              left: context.paddingLeft + 16,
              right: context.paddingRight + 32,
              top: context.paddingTop,
            ),
            child: Column(
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
                child: header,
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
        ),
      );
  }

  @override
  bool shouldRebuild(_AppHeaderDelegate old) =>
      minExtent != old.minExtent ||
      maxExtent != old.maxExtent ||
      showBackButton != old.showBackButton ||
      header != old.header;
}
