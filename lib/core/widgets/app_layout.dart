import 'dart:math' as math;

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
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: Padding(
        padding: EdgeInsetsGeometry.only(
          top: context.paddingTop > 0
            ? context.paddingTop
            : 16,
        ),
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, _) => [
            SliverPersistentHeader(
              pinned: false,
              floating: false,
              delegate: _AppHeaderDelegate(
                minExtent: context.paddingTop + kToolbarHeight,
                maxExtent: math.max(20.h, context.paddingTop + kToolbarHeight * 2),
                showBackButton: showBackButton,
                header: _buildHeader(context),
              ),
            ),
          ],
          body: Container(
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
      )
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
    final progress = (shrinkOffset / (maxExtent - minExtent))
        .clamp(0.0, 1.0);

    final currentHeight =
        math.max(minExtent, maxExtent - shrinkOffset);

    return Container(
      height: currentHeight,
      color: context.colorScheme.primary,
      padding: EdgeInsets.only(
        left: context.paddingLeft + 16,
        right: context.paddingRight + 32,
      ),
      child: Opacity(
        opacity: 1 - progress,
        child: Transform.scale(
          scale: 1 - (progress * 0.2),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: AppBackButton(),
                )
              else
                const SizedBox.shrink(),

              /// Header animando tamanho + opacidade
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: header,
                    ),
                  ),
                ),
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

