import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/home/widgets/category_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      headerText: context.l10n.appName,
      mainContainerPadding: EdgeInsets.only(
        top: 32,
        bottom: context.paddingBottom + 50,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.paddingLeft + 32,
              right: context.paddingRight + 32,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Categorias",
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Ultra',
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
                TouchableOpacity(
                  child: Text(
                    "Editar",
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const CategoryList(),
          const SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.only(
              left: context.paddingLeft + 32,
              right: context.paddingRight + 32,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Tarefas",
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Ultra',
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
