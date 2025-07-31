import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart' show Bloc, Emitter;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;

import 'json_upload_event.dart';
import 'json_upload_state.dart';
import '../../core/constants/index.dart';
import '../../data/services/algorithm_service.dart';

class JsonUploadBloc extends Bloc<JsonUploadEvent, JsonUploadState> {
  JsonUploadBloc() : super(const JsonUploadState()) {
    on<PickJsonFileEvent>(_onPickJsonFile);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<SendDataEvent>(_onSendData);
    on<ResetEvent>(_onReset);
  }

  void _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<JsonUploadState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  // Обработчик события выбора JSON-файла
  Future<void> _onPickJsonFile(
    PickJsonFileEvent event,
    Emitter<JsonUploadState> emit,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: kIsWeb,
    );
    if (result == null) return;

    final file = result.files.single;
    try {
      String content;
      // Платформозависимое чтение файла: для Web используем bytes, для остального - path
      if (kIsWeb) {
        content = utf8.decode(file.bytes!);
      } else {
        content = await File(file.path!).readAsString();
      }

      final parsed = json.decode(content);
      // Валидация структуры JSON: ожидаем список матриц
      if (parsed is List) {
        final matrices = parsed
            .map<MatrixList>((m) => (m as List)
                .map<List<int>>(
                    (r) => (r as List).map<int>((v) => v as int).toList())
                .toList())
            .toList();

        emit(state.copyWith(
          matrices: matrices,
          interpretation: '',
          algorithmResponse: null,
          showInputPanel: true,
          errorKey: null,
        ));
      } else {
        emit(state.copyWith(errorKey: 'awaitedFormat'));
      }
    } catch (_) {
      emit(state.copyWith(errorKey: 'jsonError'));
    }
  }

  // Обработчик отправки данных на сервер
  Future<void> _onSendData(
    SendDataEvent event,
    Emitter<JsonUploadState> emit,
  ) async {
    // Проверка наличия матриц и описания
    if (state.matrices == null || state.description.trim().isEmpty) {
      emit(state.copyWith(errorKey: 'inputHint'));
      return;
    }

    // Сброс предыдущих результатов перед новым запросом
    emit(state.copyWith(
      isLoading: true,
      interpretation: '',
      algorithmResponse: null,
      errorKey: null,
    ));

    try {
      final response = await AlgorithmService.sendMatricesAndGetResponse(
        matrices: state.matrices!,
        context: state.description.trim(),
      );

      if (response != null) {
        emit(state.copyWith(
          interpretation: response.interpretation,
          algorithmResponse: response,
          showInputPanel: false,
          isLoading: false,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorKey: 'sendError',
      ));
    }
  }

  void _onReset(ResetEvent event, Emitter<JsonUploadState> emit) {
    emit(const JsonUploadState());
  }
}
