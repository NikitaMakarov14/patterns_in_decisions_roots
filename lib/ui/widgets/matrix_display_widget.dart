import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'matrix_widget.dart';
import '../../data/models/algorithm_model.dart';
import '../../core/constants/index.dart';

class MatrixDisplayWidget extends StatefulWidget {
  final List<MatrixList> matrices;
  final AlgorithmResponse algorithmResponse;

  const MatrixDisplayWidget({
    super.key,
    required this.matrices,
    required this.algorithmResponse,
  });

  @override
  State<MatrixDisplayWidget> createState() => _MatrixDisplayWidgetState();
}

class _MatrixDisplayWidgetState extends State<MatrixDisplayWidget> {
  int currentPathIndex = 0;
  late final List<List<PathElement>> _allPaths;
  late final List<Map<String, dynamic>> _allPatterns;

  @override
  void initState() {
    super.initState();
    _allPaths = [];
    _allPatterns = [];

    for (final result in widget.algorithmResponse.algorithmResults) {
      for (final pattern in result.patterns) {
        _allPaths.add(pattern.path);
        _allPatterns.add(pattern.pattern);
      }
    }
  }

  // Функция для составления текста описания паттерна (преобразуем результат алгоритма в понятный для пользователя формат)
  String _describePatternWithResult(
    Map<String, dynamic> pattern,
    AlgorithmResponse response,
    AppLocalizations loc,
  ) {
    for (final result in response.algorithmResults) {
      for (final p in result.patterns) {
        if (_isMapsEqual(p.pattern, pattern)) {
          final conditions = pattern.entries
              .map((e) => '${e.key} = ${e.value}')
              .join(', ')
              .replaceAll(', ', ' & ');
          return '${loc.ifWord} $conditions, ${loc.soWord} ${result.result}';
        }
      }
    }
    return loc.emptyPattern;
  }

  bool _isMapsEqual(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }


  // Функция для преобразования номера матрицы в ее индекс для соответсвующего отображения на клиенте
  String _subscript(int number) {
    const sub = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
    return number.toString().split('').map((d) => sub[int.parse(d)]).join();
  }

  // Функция для получения ячеек матрицы, которые должно быть выделены цветом как часть паттерна
  Map<int, MatrixList> _computeHighlights({
    required List<MatrixList> matrices,
    required List<PathElement> path,
  }) {
    final result = <int, MatrixList>{};
    final userDefined = path.map((e) => e.m).whereType<int>().toSet();
    final queue = List<PathElement>.from(path);

    while (queue.isNotEmpty) {
      final p = queue.removeAt(0);
      final m = p.m;
      final value = p.value;
      final row = p.row;
      final col = p.col;

      if (m != null) {
        if (row != null && col != null) {
          result.putIfAbsent(m, () => []).add([row, col]);
        } else if (row != null) {
          result.putIfAbsent(m, () => []).add([row, -1]);
        } else if (col != null) {
          result.putIfAbsent(m, () => []).add([-1, col]);
        }

        if (m + 1 < matrices.length && !userDefined.contains(m + 1)) {
          result.putIfAbsent(m + 1, () => []).add([value, -1]);
        }

        for (int depth = m + 2; depth < matrices.length; depth++) {
          if (userDefined.contains(depth)) break;
          final prev = result[depth - 1];
          if (prev == null) break;

          final added = <List<int>>[];
          for (final hi in prev) {
            final r = hi[0] - 1;
            if (hi[1] == -1 && r >= 0 && r < matrices[depth - 1].length) {
              for (final v in matrices[depth - 1][r]) {
                added.add([v, -1]);
              }
            }
          }

          if (added.isEmpty) break;
          result.putIfAbsent(depth, () => []).addAll(added);
        }
      }
    }
    return result;
  }

  Widget _buildMatrixColumn({
    required int index,
    required MatrixList matrix,
    required MatrixList highlightedCells,
  }) {
    final isFirst = index == 0;

    final matrixWidget = MatrixWidget(
      matrix: matrix,
      highlightedCells: highlightedCells,
    );

    // Получаем индекс под матрицей
    final labelBelow = Text(
      'x${_subscript(index + 2)}',
      style: AppTextStyles.monospace(fontSize: 16),
    );

    if (isFirst) {
      // Индекс первого признака в свертке указывается слева от матрицы, а не снизу как у остальных
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.smallPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(right: AppDimensions.mediumPadding),
              child: Text(
                'x${_subscript(1)}',
                style: AppTextStyles.monospace(fontSize: 16),
              ),
            ),
            Column(
              children: [
                matrixWidget,
                SizedBox(height: AppDimensions.smallPadding),
                labelBelow,
              ],
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          matrixWidget,
          SizedBox(height: AppDimensions.smallPadding),
          labelBelow,
          SizedBox(height: AppDimensions.largePadding),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // В случае отстутствия паттернов выводим соответсвтующий текст
    if (_allPaths.isEmpty) {
      return Center(
        child: Text(
          loc.noPatterns,
          style: AppTextStyles.monospace(),
        ),
      );
    }

    final pattern = _describePatternWithResult(
      _allPatterns[currentPathIndex],
      widget.algorithmResponse,
      loc,
    );

    final highlightsMap = _computeHighlights(
      matrices: widget.matrices,
      path: _allPaths[currentPathIndex],
    );

    return Column(
      children: [
        // Навигация по паттернам
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueGrey,
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.mediumPadding),
              ),
              onPressed: currentPathIndex > 0
                  ? () => setState(() => currentPathIndex--)
                  : null,
              child: Text(
                loc.back,
                style: AppTextStyles.monospace(fontSize: 12),
              ),
            ),
            SizedBox(width: AppDimensions.mediumPadding),
            Text(
              '${loc.patternWord} ${currentPathIndex + 1} ${loc.fromWord} ${_allPaths.length}',
              style: AppTextStyles.monospace(),
            ),
            SizedBox(width: AppDimensions.mediumPadding),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueGrey,
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.mediumPadding),
              ),
              onPressed: currentPathIndex < _allPaths.length - 1
                  ? () => setState(() => currentPathIndex++)
                  : null,
              child: Text(
                loc.next,
                style: AppTextStyles.monospace(fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.mediumPadding),
        Text(
          '"$pattern"',
          style: AppTextStyles.italic(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppDimensions.largePadding),
        // Отображение матриц
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.matrices.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.mediumPadding),
                child: _buildMatrixColumn(
                  index: i,
                  matrix: widget.matrices[i],
                  highlightedCells: highlightsMap[i] ?? [],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
