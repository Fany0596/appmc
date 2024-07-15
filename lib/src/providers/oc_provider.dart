import 'dart:convert';
import 'dart:io';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:http/http.dart' as http;
import '../models/cotizacion.dart';
import '../models/user.dart';

class OcProvider extends GetConnect {

  String  url = Environment.API_URL + "api/oc";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

// para mostrar la lista de clientes
  Future<List<Oc>> getAll() async {
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

    List<Oc> oc= Oc.fromJsonList(response.body);

    return oc;
  }

  Future<Stream> create(Oc oc, List<File> images) async{
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/oc/create');
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

    request.fields['oc'] = json.encode(oc);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // para mostrar la lista por status
  Future<List<Oc>> findByStatus(String status) async {
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

    List<Oc> oc= Oc.fromJsonList(response.body);

    return oc;
  }
  Future<Oc?> getOcByCotizacion(String cotizacionId) async {
    try {
      final response = await http.get(
        Uri.parse('https://nodejsmc.onrender.com/api/oc/getOcByCotizacion/$cotizacionId'),
        headers: {
          'Authorization': userSession.sessionToken ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final ocData = responseData['data'][0]; // Adjust this if necessary
          return Oc.fromJson(ocData);
        } else {
          print('API returned success: false');
          return null;
        }
      } else {
        print('Failed to load OC, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getOcByCotizacion: $e');
      return null;
    }
  }
  Future<ResponseApi> updatecerrada(Oc oc) async {
    Response response = await put(
        '$url/updatecerrada',
        oc.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> updatecancelada(Oc oc) async {
    Response response = await put(
        '$url/updatecancelada',
        oc.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> updategenerada(Oc oc) async {
    Response response = await put(
        '$url/updategenerada',
        oc.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    ); // ESPERAR HASTA QUE EL SERVIDOR NOS RETORNE LA RESPUESTA

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> deleted(String ocId) async {
    final response = await delete(
        '$url/deleted/$ocId',
        headers: {
          //'Content-Type': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': userSession.sessionToken ?? ''
        });

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401){
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

}

