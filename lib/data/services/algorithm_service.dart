import 'package:dio/dio.dart';
import '../models/algorithm_model.dart';
import '../../core/constants/index.dart';

class AlgorithmService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );

  static Future<AlgorithmResponse?> sendMatricesAndGetResponse({
    required List<dynamic> matrices,
    required String context,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.findPatternsEndpoint,
        data: {
          'matrices': matrices,
          'context': context,
        },
      );

      if (response.statusCode == 200) {
        return AlgorithmResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static void _handleDioError(DioException e) {
    if (e.response != null) {
      throw Exception(
        'Server error ${e.response!.statusCode}: ${e.response!.data}',
      );
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}
