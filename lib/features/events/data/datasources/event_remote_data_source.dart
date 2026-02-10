import 'package:http/http.dart' as http;

abstract class EventRemoteDataSource {
  // El data source ahora puede ser más simple y enfocado en operaciones específicas de datos
  // Los métodos fetchAllAttendees y getEvents se movieron a EventService
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final http.Client client;

  EventRemoteDataSourceImpl({required this.client});

  // Aquí puedes agregar métodos más específicos del data source
  // como operaciones CRUD individuales, cacheo, etc.
}
