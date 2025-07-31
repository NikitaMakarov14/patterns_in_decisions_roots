import 'package:equatable/equatable.dart' show Equatable;

abstract class JsonUploadEvent extends Equatable {
  const JsonUploadEvent();

  @override
  List<Object> get props => [];
}

// Событие выбора файла с матрицами
class PickJsonFileEvent extends JsonUploadEvent {}

// Событие обновления описания матриц
class UpdateDescriptionEvent extends JsonUploadEvent {
  final String description;

  const UpdateDescriptionEvent(this.description);

  @override
  List<Object> get props => [description];
}

// Событие отправки данных
class SendDataEvent extends JsonUploadEvent {}

// Событие сброса состояния до начального
class ResetEvent extends JsonUploadEvent {}
