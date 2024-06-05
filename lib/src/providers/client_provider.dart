import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import '../models/user.dart';

class ClientesProvider extends GetConnect {

  String  url = Environment.API_URL + "api/cliente";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});
// para mostrar la lista de clientes
  Future<List<Clientes>> getAll() async {
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

    List<Clientes> clientes = Clientes.fromJsonList(response.body);

    return clientes;
  }
  // crear un nuevo cliente
  Future<ResponseApi> create(Clientes clientes) async {
    Response response = await post(
        '$url/create',
        clientes.toJson(),
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