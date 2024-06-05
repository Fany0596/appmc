import 'dart:convert';
import 'dart:io';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ProductoProvider extends GetConnect {
  String  url = Environment.API_URL + "api/producto";
  String  urll = Environment.API_URL + "api";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<ResponseApi> generar(Producto producto) async {
    Response response = await put(
        '$url/generar',
        producto.toJson(),
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
  Future<ResponseApi> cancelar(Producto producto) async {
    Response response = await put(
        '$url/updatec',
        producto.toJson(),
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

  Future<ResponseApi> updated(Producto producto) async {
    Response response = await put(
        '$url/updated',
        producto.toJson(),
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

  Future<Stream?> update(Producto producto, List<File> images, productId) async{
    // Verifica si el ID del producto está definido y no es nulo o vacío
    if (producto.id == null || producto.id!.isEmpty) {
      print('El ID del producto no está definido o es vacío');
      // Puedes manejar este caso como desees, por ejemplo, lanzando una excepción o mostrando un mensaje de error.
      return null;
    }
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/updated');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = userSession.sessionToken ?? '';

    for (int i = 0; i <images.length; i++){
      request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(images[i].openRead().cast()),
          await images[i].length(),
          filename: basename(images[i].path)

      ));
    }

    request.fields['producto'] = json.encode(producto);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  Future<List<Producto>> getProductosFromCotizacion(int cotizacionId) async {
    try {
      final response = await http.get(Uri.parse('$urll/cotizacion/getProductosFromCotizacion'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load productos from cotizacion');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Stream> create(Producto producto, List<File> images) async{
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/create');
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

    request.fields['producto'] = json.encode(producto);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }
  // para mostrar la lista por status
  Future<List<Producto>> findByStatus(String estatus) async {
    Response response = await get(
        '$url/findByStatus/$estatus',
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401){
      Get.snackbar('Petición denegada', 'Tu usuario no puede leer esta informacion');
      return[];
    }

    List<Producto> producto=Producto.fromJsonList(response.body);
    print('Productos recibidos del servidor: $producto');
    return producto;
  }

}
