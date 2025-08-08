import 'dart:collection';
import 'dart:async';
import 'dart:isolate';

import '../models/algorithm_model.dart';
import '../../core/constants/index.dart';

typedef HighlightResult = Map<int, List<List<int>>>;

Future<HighlightResult> computeHighlightsIsolate({
  required List<MatrixList> matrices,
  required List<PathElement> path,
}) async {
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(
    _isolateEntry,
    _IsolateData(
      matrices: matrices,
      path: path,
      sendPort: receivePort.sendPort,
    ),
  );
  try {
    return await receivePort.first as HighlightResult;
  } finally {
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

void _isolateEntry(_IsolateData data) {
  final result = _computeHighlights(
    matrices: data.matrices,
    path: data.path,
  );
  data.sendPort.send(result);
}

HighlightResult _computeHighlights({
  required List<MatrixList> matrices,
  required List<PathElement> path,
}) {
  final result = <int, Set<List<int>>>{};
  final userDefined = path.map((e) => e.m).whereType<int>().toSet();
  final queue = Queue<PathElement>.from(path);

  while (queue.isNotEmpty) {
    final p = queue.removeFirst();
    final m = p.m;
    final value = p.value;
    final row = p.row;
    final col = p.col;

    if (m == null) continue;

    // Обработка текущего элемента
    if (row != null && col != null) {
      result.putIfAbsent(m, () => {}).add([row, col]);
    } else if (row != null) {
      result.putIfAbsent(m, () => {}).add([row, -1]);
    } else if (col != null) {
      result.putIfAbsent(m, () => {}).add([-1, col]);
    }

    // Распространение влияния на следующий слой
    final nextLayer = m + 1;
    if (nextLayer < matrices.length && 
        !userDefined.contains(nextLayer)) {
      result.putIfAbsent(nextLayer, () => {}).add([value, -1]);
    }

    // Каскадное распространение на глубокие слои
    for (int depth = m + 2; depth < matrices.length; depth++) {
      if (userDefined.contains(depth)) break;
      
      final prevLayerHighlights = result[depth - 1];
      if (prevLayerHighlights == null || prevLayerHighlights.isEmpty) break;

      final added = <List<int>>{};
      for (final hi in prevLayerHighlights) {
        // Обрабатываем только подсветки строк
        if (hi[1] != -1) continue;
        
        final r = hi[0] - 1;
        if (r < 0 || r >= matrices[depth - 1].length) continue;
        
        // Для каждой строки собираем уникальные значения
        for (final v in matrices[depth - 1][r]) {
          added.add([v, -1]);
        }
      }

      if (added.isEmpty) break;
      result.putIfAbsent(depth, () => {}).addAll(added);
    }
  }

  return result.map((key, value) => MapEntry(key, value.toList()));
}

class _IsolateData {
  final List<MatrixList> matrices;
  final List<PathElement> path;
  final SendPort sendPort;

  _IsolateData({
    required this.matrices,
    required this.path,
    required this.sendPort,
  });
}
