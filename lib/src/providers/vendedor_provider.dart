import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import '../models/user.dart';

class VendedoresProvider extends GetConnect {

  String  url = Environment.API_URL + "api/vendedor";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // para mostrar la lista de vendedores
  Future<List<Vendedores>> getAll() async {
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

    List<Vendedores> vendedores = Vendedores.fromJsonList(response.body);

    return vendedores;
  }

  Future<ResponseApi> create(Vendedores vendedores) async {
    Response response = await post(
        '$url/create',
        vendedores.toJson(),
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