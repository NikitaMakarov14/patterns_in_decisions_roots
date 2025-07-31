import 'package:json_annotation/json_annotation.dart';

part 'algorithm_model.g.dart';

@JsonSerializable()
class AlgorithmResult {
  final List<AlgorithmPattern> patterns;
  final int result;

  AlgorithmResult({required this.patterns, required this.result});

  factory AlgorithmResult.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmResultFromJson(json);
  Map<String, dynamic> toJson() => _$AlgorithmResultToJson(this);
}

@JsonSerializable()
class AlgorithmPattern {
  final List<PathElement> path;
  final Map<String, dynamic> pattern;

  AlgorithmPattern({required this.path, required this.pattern});

  factory AlgorithmPattern.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmPatternFromJson(json);
  Map<String, dynamic> toJson() => _$AlgorithmPatternToJson(this);
}

@JsonSerializable()
class PathElement {
  final int? m;
  final int? row;
  final int? col;
  final int value;

  PathElement({
    this.m,
    this.row,
    this.col,
    required this.value,
  });

  factory PathElement.fromJson(Map<String, dynamic> json) =>
      _$PathElementFromJson(json);
  Map<String, dynamic> toJson() => _$PathElementToJson(this);
}

@JsonSerializable()
class AlgorithmResponse {
  @JsonKey(name: 'algorithm_results')
  final List<AlgorithmResult> algorithmResults;
  final String interpretation;

  AlgorithmResponse({
    required this.algorithmResults,
    required this.interpretation,
  });

  factory AlgorithmResponse.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AlgorithmResponseToJson(this);
}
