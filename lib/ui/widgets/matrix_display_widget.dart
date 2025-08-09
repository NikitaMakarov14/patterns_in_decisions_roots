import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';

import 'matrix_widget.dart';
import '../../data/services/highlight_isolate.dart';
import '../../data/models/algorithm_model.dart';
import '../../core/constants/index.dart';

typedef HighlightResult = Map<int, List<Highlight>>;

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
  final Map<int, HighlightResult> _highlightsCache = {}; //кэшируем паттерны

  // Храним текущие и предыдущие подсветки для анимации
  HighlightResult? _currentHighlights;
  HighlightResult? _previousHighlights;
  Future<HighlightResult>? _highlightsFuture;

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
    _computeHighlights();
  }

  // Конвертация старых данных в новую типизацию
  HighlightResult _convertToNewFormat(Map<int, List<List<int>>> oldResult) {
    final newResult = <int, List<Highlight>>{};

    for (final entry in oldResult.entries) {
      final highlights = <Highlight>[];

      for (final coords in entry.value) {
        final row = coords[0];
        final col = coords[1];

        if (row != -1 && col != -1) {
          highlights.add(CellHighlight(row, col));
        } else if (row != -1) {
          highlights.add(RowHighlight(row));
        } else if (col != -1) {
          highlights.add(ColHighlight(col));
        }
      }

      newResult[entry.key] = highlights;
    }

    return newResult;
  }

  void _computeHighlights() {
    // Проверяем кэш перед запуском изолята
    if (_highlightsCache.containsKey(currentPathIndex)) {
      setState(() {
        _previousHighlights = _currentHighlights;
        _currentHighlights = _highlightsCache[currentPathIndex];
      });
      return;
    }

    setState(() {
      _previousHighlights = _currentHighlights;
      _highlightsFuture = computeHighlightsIsolate(
        matrices: widget.matrices,
        path: _allPaths[currentPathIndex],
      ).then((oldResult) => _convertToNewFormat(oldResult));

      _highlightsFuture!.then((result) {
        if (mounted) {
          setState(() {
            _currentHighlights = result;
            _highlightsCache[currentPathIndex] = result; // Сохраняем в кэш
            _previousHighlights = null;
          });
        }
      });
    });
  }

  // Функция для составления текста описания паттерна
  String _describePatternWithResult(
    Map<String, dynamic> pattern,
    AlgorithmResponse response,
    AppLocalizations loc,
  ) {
    for (final result in response.algorithmResults) {
      for (final p in result.patterns) {
        if (const DeepCollectionEquality().equals(p.pattern, pattern)) {
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

  // Функция для преобразования номера матрицы в ее индекс
  String _subscript(int number) {
    const sub = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
    return number.toString().split('').map((d) => sub[int.parse(d)]).join();
  }

  Widget _buildMatrixColumn({
    required int index,
    required MatrixList matrix,
    required List<Highlight> highlights,
  }) {
    final isFirst = index == 0;

    final matrixWidget = MatrixWidget(
      matrix: matrix,
      highlights: highlights,
    );

    final labelBelow = Text(
      'x${_subscript(index + 2)}',
      style: AppTextStyles.monospace(fontSize: 16),
    );

    if (isFirst) {
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

    return Column(
      children: [
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
                  ? () {
                      setState(() => currentPathIndex--);
                      _computeHighlights();
                    }
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
                  ? () {
                      setState(() => currentPathIndex++);
                      _computeHighlights();
                    }
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _MatrixDisplaySection(
            key: ValueKey<int>(currentPathIndex),
            matrices: widget.matrices,
            currentHighlights: _currentHighlights,
            previousHighlights: _previousHighlights,
            buildMatrixColumn: _buildMatrixColumn,
            isLoading: _currentHighlights == null,
          ),
        ),
      ],
    );
  }
}

class _MatrixDisplaySection extends StatelessWidget {
  final List<MatrixList> matrices;
  final HighlightResult? currentHighlights;
  final HighlightResult? previousHighlights;
  final Widget Function({
    required int index,
    required MatrixList matrix,
    required List<Highlight> highlights,
  }) buildMatrixColumn;
  final bool isLoading;

  const _MatrixDisplaySection({
    required Key key,
    required this.matrices,
    required this.currentHighlights,
    required this.previousHighlights,
    required this.buildMatrixColumn,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final highlightsToUse = currentHighlights ?? previousHighlights ?? {};

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(matrices.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.mediumPadding),
            child: buildMatrixColumn(
              index: i,
              matrix: matrices[i],
              highlights: highlightsToUse[i] ?? [],
            ),
          );
        }),
      ),
    );
  }
}
