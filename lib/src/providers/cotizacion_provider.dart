import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:http/http.dart' as http;
import '../models/cotizacion.dart';
import '../models/user.dart';

class CotizacionProvider extends GetConnect {

  String  url = Environment.API_URL + "api/cotizacion";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

// para mostrar la lista de clientes
  Future<List<Cotizacion>> getAll() async {
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

    List<Cotizacion> cotizacion= Cotizacion.fromJsonList(response.body);

    return cotizacion;
  }

  Future<Stream> create(Cotizacion cotizacion, List<File> images) async{
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/cotizacion/create');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = userSession.sessionToken ?? '';

    for (int i = 0; i <images.length; i++){
      request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(images[i].openRead().cast()),
          await images[i].length(),
          filename: basename(images[i].path)

      ));
    }

    request.fields['cotizacion'] = json.encode(cotizacion);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // para mostrar la lista por status
  Future<List<Cotizacion>> findByStatus(String status) async {
    Response response = await get(
        '$url/findByStatus/$status',
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401){
      Get.snackbar('Petición denegada', 'Tu usuario no puede leer esta informacion');
      return[];
    }

    List<Cotizacion> cotizacion= Cotizacion.fromJsonList(response.body);

    return cotizacion;
  }

  Future<ResponseApi> updateconfirmada(Cotizacion cotizacion) async {
    Response response = await put(
        '$url/updateconfirmada',
        cotizacion.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> updatecancelada(Cotizacion cotizacion) async {
    Response response = await put(
        '$url/updatecancelada',
        cotizacion.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> updatecerrada(Cotizacion cotizacion) async {
    Response response = await put(
        '$url/updatecerrada',
        cotizacion.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> updategenerada(Cotizacion cotizacion) async {
    Response response = await put(
        '$url/updategenerada',
        cotizacion.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

}

