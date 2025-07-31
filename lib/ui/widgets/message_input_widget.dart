import 'package:flutter/material.dart';

import '../../core/constants/index.dart';

class MessageInputWidget extends StatelessWidget {
  final TextEditingController descriptionController;
  final bool hasFile;
  final VoidCallback onPickFile;
  final VoidCallback onSend;
  final ValueChanged<String> onDescriptionChanged;
  final String hintText;

  const MessageInputWidget({
    super.key,
    required this.descriptionController,
    required this.hasFile,
    required this.onPickFile,
    required this.onSend,
    required this.onDescriptionChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.secondaryDark,
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadius * 1.5,
          ),
          border: Border.all(color: AppColors.white24),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.mediumPadding,
        ),
        child: Row(
          children: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: hasFile
                    ? Icon(Icons.check_circle,
                        key: const ValueKey('check'),
                        color: AppColors.greenAccent)
                    : Icon(Icons.add_circle_outline,
                        key: const ValueKey('add'), color: AppColors.white70),
              ),
              iconSize: AppDimensions.largePadding,
              onPressed: onPickFile,
            ),
            Expanded(
              child: TextField(
                controller: descriptionController,
                onChanged: onDescriptionChanged,
                style: AppTextStyles.monospace(),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTextStyles.monospace(color: AppColors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              color: AppColors.white,
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
