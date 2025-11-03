import 'package:http/http.dart' as http;
import 'package:alice/alice.dart';
import 'alice_service.dart';

class AliceHttpClient extends http.BaseClient {
  final http.Client _client;
  final Alice _alice = AliceService.alice;

  AliceHttpClient(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _alice.onHttpClientRequest(request);
    final Future<http.StreamedResponse> response = _client.send(request);
    response.then((r) {
      _alice.onHttpClientResponse(r, request);
    });
    return response;
  }
}
