import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/utils/app_max_width.dart';


class LevelUpBanner extends StatefulWidget {
  const LevelUpBanner({
    super.key,
    required this.title,
    required this.onDismiss,
  });

  final String title;
  final VoidCallback onDismiss;

  @override
  State<LevelUpBanner> createState() => _LevelUpBannerState();
}

class _LevelUpBannerState extends State<LevelUpBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final int _subtitleIndex;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _subtitleIndex = Random().nextInt(10);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween(begin: const Offset(0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted || _dismissed) return;
    _dismissed = true;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtitles = [
      context.l10n.levelUpSubtitle1,
      context.l10n.levelUpSubtitle2,
      context.l10n.levelUpSubtitle3,
      context.l10n.levelUpSubtitle4,
      context.l10n.levelUpSubtitle5,
      context.l10n.levelUpSubtitle6,
      context.l10n.levelUpSubtitle7,
      context.l10n.levelUpSubtitle8,
      context.l10n.levelUpSubtitle9,
      context.l10n.levelUpSubtitle10,
    ];

    return Positioned(
      top: context.paddingTop + 12,
      left: 0,
      right: 0,
      child: Align(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: appMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    color: context.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: context.textTheme.displayMedium!.fontSize! * 1.71,
                            height: context.textTheme.displayMedium!.fontSize! * 1.71,
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Ionicons.trophy_outline,
                              color: context.colorScheme.onPrimary,
                              size: context.textTheme.displayMedium!.fontSize,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitles[_subtitleIndex],
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
