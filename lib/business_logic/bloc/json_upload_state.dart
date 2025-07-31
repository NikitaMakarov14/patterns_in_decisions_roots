import 'package:equatable/equatable.dart' show Equatable;

import '../../data/models/algorithm_model.dart';
import '../../core/constants/index.dart';

class JsonUploadState extends Equatable {
  final List<MatrixList>? matrices; // Загруженные матрицы
  final String
      description; // Пользовательский комментарий к матрицам (контекст для языковой модели)
  final bool isLoading; // Флаг загрузки данных
  final String interpretation; // Полученные данные от языковой модели
  final AlgorithmResponse? algorithmResponse; // Данные из ответа от сервера
  final bool
      showInputPanel; // Флаг для панели с вводом и загрузкой пользовательских данных
  final String? errorKey; // Ключ ошибки для локализации

  const JsonUploadState({
    this.matrices,
    this.description = '',
    this.isLoading = false,
    this.interpretation = '',
    this.algorithmResponse,
    this.showInputPanel = true,
    this.errorKey,
  });

  JsonUploadState copyWith({
    List<MatrixList>? matrices,
    String? description,
    bool? isLoading,
    String? interpretation,
    AlgorithmResponse? algorithmResponse,
    bool? showInputPanel,
    String? errorKey,
  }) {
    return JsonUploadState(
      matrices: matrices ?? this.matrices,
      description: description ?? this.description,
      isLoading: isLoading ?? this.isLoading,
      interpretation: interpretation ?? this.interpretation,
      algorithmResponse: algorithmResponse ?? this.algorithmResponse,
      showInputPanel: showInputPanel ?? this.showInputPanel,
      errorKey: errorKey,
    );
  }

  @override
  List<Object?> get props => [
        matrices,
        description,
        isLoading,
        interpretation,
        algorithmResponse,
        showInputPanel,
        errorKey,
      ];
}
