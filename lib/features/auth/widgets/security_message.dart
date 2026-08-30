import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SecurityMessage extends StatelessWidget {
  const SecurityMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your information is encrypted and secure',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your information is encrypted and secure',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
