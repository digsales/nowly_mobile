import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:sizer/sizer.dart';

/// Reusable bottom sheet with a drag handle, scrollable content,
/// and consistent padding.
///
/// Use the static [show] method for convenience:
///
/// ```dart
/// AppBottomSheet.show(
///   context: context,
///   builder: (context) => Column(
///     children: [
///       Text('Hello'),
///     ],
///   ),
/// );
/// ```
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
  });

  final Widget child;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(
        child: builder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Device.orientation == Orientation.portrait ? context.paddingLeft + 32 : 32,
              0,
              Device.orientation == Orientation.portrait ? context.paddingLeft + 32 : 32,
              context.paddingBottom + 32
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
