// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algorithm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlgorithmResult _$AlgorithmResultFromJson(Map<String, dynamic> json) =>
    AlgorithmResult(
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => AlgorithmPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: (json['result'] as num).toInt(),
    );

Map<String, dynamic> _$AlgorithmResultToJson(AlgorithmResult instance) =>
    <String, dynamic>{
      'patterns': instance.patterns,
      'result': instance.result,
    };

AlgorithmPattern _$AlgorithmPatternFromJson(Map<String, dynamic> json) =>
    AlgorithmPattern(
      path: (json['path'] as List<dynamic>)
          .map((e) => PathElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      pattern: json['pattern'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AlgorithmPatternToJson(AlgorithmPattern instance) =>
    <String, dynamic>{
      'path': instance.path,
      'pattern': instance.pattern,
    };

PathElement _$PathElementFromJson(Map<String, dynamic> json) => PathElement(
      m: (json['m'] as num?)?.toInt(),
      row: (json['row'] as num?)?.toInt(),
      col: (json['col'] as num?)?.toInt(),
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$PathElementToJson(PathElement instance) =>
    <String, dynamic>{
      'm': instance.m,
      'row': instance.row,
      'col': instance.col,
      'value': instance.value,
    };

AlgorithmResponse _$AlgorithmResponseFromJson(Map<String, dynamic> json) =>
    AlgorithmResponse(
      algorithmResults: (json['algorithm_results'] as List<dynamic>)
          .map((e) => AlgorithmResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      interpretation: json['interpretation'] as String,
    );

Map<String, dynamic> _$AlgorithmResponseToJson(AlgorithmResponse instance) =>
    <String, dynamic>{
      'algorithm_results': instance.algorithmResults,
      'interpretation': instance.interpretation,
    };
