import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_back_button.dart';
import 'package:nowly/core/widgets/app_title.dart';
import 'package:sizer/sizer.dart';

/// Page layout for authenticated screens.
///
/// Has a primary-colored header and a surface-colored body with
/// rounded top corners. The header scrolls away with a fade + scale animation.
///
/// ```dart
/// AppLayout(
///   headerText: 'Início',
///   body: Column(children: [...]),
/// )
/// ```
class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    this.headerText,
    this.headerHelpTitle,
    this.headerHelpText,
    this.headerBuilder,
    this.showBackButton = false,
    this.onRefresh,
    this.bodyPadding,
    required this.body,
  });

  /// Simple text header (styled with Ultra font)
  final String? headerText;

  /// Custom title for the help sheet. Defaults to [headerText] when omitted.
  final String? headerHelpTitle;

  /// Help text shown in the help sheet. When non-null, a help icon
  /// appears next to the header title.
  final String? headerHelpText;

  /// Custom header builder (takes priority over headerText)
  final WidgetBuilder? headerBuilder;

  /// Show back button to return to previous route
  final bool showBackButton;

  /// Pull-to-refresh callback. When non-null, wraps the scroll view
  /// in a [RefreshIndicator].
  final RefreshCallback? onRefresh;

  /// Custom padding for the body area. When null, uses the default
  /// (32px horizontal + safe area, 32px top, 50px + safe area bottom).
  final EdgeInsets? bodyPadding;

  /// Main content
  final Widget body;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scrollView = NestedScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final offset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                final progress = (offset / 20.h).clamp(0.0, 1.0);

                return Opacity(
                  opacity: 1 - progress,
                  child: Transform.scale(
                    scale: 1 - (progress * 0.7),
                    alignment: Alignment.bottomLeft,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: context.paddingLeft + 16,
                  right: context.paddingRight + 32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showBackButton)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: AppBackButton(),
                        )
                      else
                        const SizedBox(height: 0),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _buildHeader(context),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: _buildBody(context),
    );

    return Scaffold(body: scrollView);
  }

  Widget _buildBody(BuildContext context) {
    final content = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: widget.bodyPadding ??
                EdgeInsets.only(
                  top: 32,
                  left: context.paddingLeft + 32,
                  right: context.paddingRight + 32,
                  bottom: context.paddingBottom + 50,
                ),
            sliver: SliverToBoxAdapter(child: widget.body),
          ),
        ],
      ),
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    if (widget.headerBuilder != null) return widget.headerBuilder!(context);
    if (widget.headerText != null) {
      return AppTitle(
        title: widget.headerText!,
        titleColor: context.colorScheme.onPrimary,
        helpTitle: widget.headerHelpTitle,
        helpText: widget.headerHelpText,
      );
    }
    return const SizedBox.shrink();
  }
}
