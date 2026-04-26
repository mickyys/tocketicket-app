import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tocke/core/constants/app_constants.dart';
import 'package:tocke/core/services/auth_service.dart';
import 'package:tocke/core/utils/http_header_utils.dart';
import 'package:tocke/features/search/data/models/rut_ticket_search_result_model.dart';

class RutTicketSearchService {
  final http.Client client;

  const RutTicketSearchService({required this.client});

  Future<List<RutTicketSearchResultModel>> searchByDocument({
    required String documentType,
    required String documentNumber,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesion no autenticada');
    }

    final backendDocumentType =
        documentType.toLowerCase() == 'rut' ? 'RUT' : documentType;

    final uri = Uri.parse(
      AppConstants.organizerTicketSearchByDocumentEndpoint,
    ).replace(
      queryParameters: {
        'documentType': backendDocumentType,
        'documentNumber': documentNumber,
      },
    );

    final response = await client.get(
      uri,
      headers: HttpHeaderUtils.getAuthHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al buscar tickets: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['data'] as List? ?? []);

    return items
        .map((item) => RutTicketSearchResultModel.fromJson(item))
        .toList();
  }
}
