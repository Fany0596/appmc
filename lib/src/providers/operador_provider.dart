import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/operador.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import '../models/user.dart';

class OperadorProvider extends GetConnect {

  String  url = Environment.API_URL + "api/operador";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // para mostrar la lista de vendedores
  Future<List<Operador>> getAll() async {
    Response response = await get(
        '$url/getAll',
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401){
      Get.snackbar('Petición denegada', 'Tu usuario no puede leer esta informacion');
      return[];
    }

    List<Operador> operador = Operador.fromJsonList(response.body);

    return operador;
  }

  Future<ResponseApi> create(Operador operador) async {
    Response response = await post(
        '$url/create',
        operador.toJson(),
        //contentType: 'application/json; charset=UTF-8',
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
}