import 'package:maquinados_correa/src/models/promedio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import '../models/user.dart';

class PromedioProvider extends GetConnect {

  String url = Environment.API_URL + "api/promedio";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // para mostrar la lista por status
  Future<List<Promedio>> findByStatus(String parte) async {
    Response response = await get(
        '$url/getAll/$parte',
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401){
      Get.snackbar('Petición denegada', 'Tu usuario no puede leer esta informacion');
      return[];
    }

    List<Promedio> promedio= Promedio.fromJsonList(response.body);

    return promedio;
  }
}