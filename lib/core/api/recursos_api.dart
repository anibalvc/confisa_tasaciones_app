import 'package:tasaciones_app/core/api/http.dart';
import 'package:tasaciones_app/core/models/recursos_response.dart';

import '../authentication_client.dart';

class RecursosAPI {
  final Http _http;
  final AuthenticationClient _authenticationClient;
  RecursosAPI(this._http, this._authenticationClient);

  Future<Object> getRecursos(
      {int pageNumber = 1, int pageSize = 100, int estado = 1}) async {
    String _token = await _authenticationClient.accessToken;
    return _http.request(
      '/api/recursos/get?PageSize=$pageSize&PageNumber=$pageNumber&Estado=$estado',
      method: 'GET',
      headers: {
        'Authorization': 'Bearer $_token',
      },
      parser: (data) {
        return RecursosResponse.fromJson(data);
      },
    );
  }

  Future<Object> createRecursos({required String name}) async {
    String _token = await _authenticationClient.accessToken;
    return _http.request(
      '/api/recursos/create',
      method: 'POST',
      headers: {
        'Authorization': 'Bearer $_token',
      },
      data: {
        "nombre": name,
      },
    );
  }

  Future<Object> updateRecursos({
    required int id,
    required String nombre,
    required int estado,
    required int idModulo,
  }) async {
    String _token = await _authenticationClient.accessToken;
    return _http.request(
      '/api/acciones/update',
      method: "PUT",
      headers: {
        'Authorization': 'Bearer $_token',
      },
      data: {
        "id": id,
        "nombre": nombre,
        "estado": estado,
        "idModulo": idModulo,
      },
    );
  }

  Future<Object> deleteRecursos({required int id}) async {
    String _token = await _authenticationClient.accessToken;
    return _http.request(
      '/api/recursos/update',
      method: "DELETE",
      headers: {
        'Authorization': 'Bearer $_token',
      },
      queryParameters: {
        "id": id,
      },
    );
  }
}
