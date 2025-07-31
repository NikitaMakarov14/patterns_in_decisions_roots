import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart'
    show AnimatedTextKit, TypewriterAnimatedText;

import '../../core/constants/index.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isInterpretation;

  const ChatBubbleWidget({
    super.key,
    required this.text,
    this.isUser = false,
    this.isInterpretation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.symmetric(vertical: AppDimensions.smallPadding),
        padding: const EdgeInsets.all(AppDimensions.mediumPadding),
        decoration: BoxDecoration(
          color: isUser ? AppColors.chatBubbleUser : AppColors.chatBubbleBot,
          borderRadius:
              BorderRadius.circular(AppDimensions.chatBubbleBorderRadius),
        ),
        child: isInterpretation
            ? AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    text,
                    textStyle: AppTextStyles.monospace(fontSize: 12),
                    speed: const Duration(milliseconds: 50),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              )
            : Text(text, style: AppTextStyles.monospace(fontSize: 12)),
      ),
    );
  }
}
