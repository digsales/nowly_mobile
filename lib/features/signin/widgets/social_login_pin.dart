import 'package:flutter/material.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

class SocialLoginPin extends StatelessWidget {
  const SocialLoginPin({
    super.key,
    required this.image,
    this.onPressed,
  });

  final String image;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover
          ),
        ),
      ),
    );
  }
}