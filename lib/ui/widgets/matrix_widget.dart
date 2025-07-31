import 'package:flutter/material.dart';

import '../../core/constants/index.dart';

class MatrixWidget extends StatelessWidget {
  final MatrixList matrix;
  final MatrixList
      highlightedCells; // Все ячейки, которые учавствуют в отображении паттерна

  const MatrixWidget({
    super.key,
    required this.matrix,
    required this.highlightedCells,
  });

  // Функия для определения является ли ячейка частью паттерна
  bool _isHighlighted(int row, int col) {
    return highlightedCells.any((coords) =>
        (coords[0] == row && (coords[1] == -1 || coords[1] == col)) ||
        (coords[0] == -1 && coords[1] == col));
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: AppColors.white24,
        width: 1.0,
        borderRadius: BorderRadius.circular(AppDimensions.smallPadding),
      ),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: List.generate(matrix.length, (r) {
        return TableRow(
          decoration: BoxDecoration(
            color: (r % 2 == 0)
                ? AppColors.primaryDark.withOpacity(0.1)
                : AppColors.secondaryDark.withOpacity(0.1),
          ),
          children: List.generate(matrix[r].length, (c) {
            final isHigh = _isHighlighted(r + 1, c + 1);
            // Используем AnimatedContainer для интерактивного изменения цвета ячейки
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                vertical: AppDimensions.smallPadding,
                horizontal: AppDimensions.mediumPadding,
              ),
              decoration: BoxDecoration(
                color: isHigh ? AppColors.yellowHighlight : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '${matrix[r][c]}',
                  style: AppTextStyles.monospace(
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
