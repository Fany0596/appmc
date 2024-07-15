import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/comprador.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import '../models/user.dart';

class CompradorProvider extends GetConnect {

  String  url = Environment.API_URL + "api/comprador";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // para mostrar la lista de vendedores
  Future<List<Comprador>> getAll() async {
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

    List<Comprador> comprador = Comprador.fromJsonList(response.body);

    return comprador;
  }

  Future<ResponseApi> create(Comprador comprador) async {
    Response response = await post(
        '$url/create',
        comprador.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
}