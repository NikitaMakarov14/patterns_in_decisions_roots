import 'package:flutter/material.dart';

import '../../core/constants/index.dart';

// Создаем sealed классы для типизации подсветки
sealed class Highlight {}

class CellHighlight implements Highlight {
  final int row;
  final int col;
  
  CellHighlight(this.row, this.col);
}

class RowHighlight implements Highlight {
  final int row;
  
  RowHighlight(this.row);
}

class ColHighlight implements Highlight {
  final int col;
  
  ColHighlight(this.col);
}

class MatrixWidget extends StatelessWidget {
  final MatrixList matrix;
  final List<Highlight> highlights; 

  const MatrixWidget({
    super.key,
    required this.matrix,
    required this.highlights,
  });

  // Оптимизированная проверка подсветки
  bool _isHighlighted(int row, int col) {
    final highlightedRows = highlights
        .whereType<RowHighlight>()
        .map((h) => h.row)
        .toSet();
    
    final highlightedCols = highlights
        .whereType<ColHighlight>()
        .map((h) => h.col)
        .toSet();
    
    final highlightedCells = highlights
        .whereType<CellHighlight>()
        .map((h) => '${h.row},${h.col}')
        .toSet();
    
    return highlightedRows.contains(row) ||
           highlightedCols.contains(col) ||
           highlightedCells.contains('$row,$col');
  }

  BorderRadius _getCellBorderRadius(int rowIndex, int colIndex) {
    final bool isFirstRow = rowIndex == 0;
    final bool isLastRow = rowIndex == matrix.length - 1;
    final bool isFirstCol = colIndex == 0;
    final bool isLastCol = colIndex == matrix[rowIndex].length - 1;

    return BorderRadius.only(
      topLeft: (isFirstRow && isFirstCol)
          ? const Radius.circular(AppDimensions.smallPadding)
          : Radius.zero,
      topRight: (isFirstRow && isLastCol)
          ? const Radius.circular(AppDimensions.smallPadding)
          : Radius.zero,
      bottomLeft: (isLastRow && isFirstCol)
          ? const Radius.circular(AppDimensions.smallPadding)
          : Radius.zero,
      bottomRight: (isLastRow && isLastCol)
          ? const Radius.circular(AppDimensions.smallPadding)
          : Radius.zero,
    );
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
          children: List.generate(matrix[r].length, (c) {
            final isHigh = _isHighlighted(r + 1, c + 1);
            final cellBorderRadius = _getCellBorderRadius(r, c);

            return Container(
              decoration: BoxDecoration(
                color: (r % 2 == 0)
                    ? AppColors.primaryDark.withOpacity(0.1)
                    : AppColors.secondaryDark.withOpacity(0.1),
                borderRadius: cellBorderRadius,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.smallPadding,
                  horizontal: AppDimensions.mediumPadding,
                ),
                decoration: BoxDecoration(
                  color:
                      isHigh ? AppColors.yellowHighlight : Colors.transparent,
                  borderRadius: cellBorderRadius,
                ),
                child: Center(
                  child: Text(
                    '${matrix[r][c]}',
                    style: AppTextStyles.monospace(fontSize: 14),
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