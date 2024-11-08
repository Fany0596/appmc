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
  String url = Environment.API_URL + "api/producto";
  String urll = Environment.API_URL + "api";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<ResponseApi> generar(Producto producto) async {
    Response response = await put('$url/generar', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> cancelar(Producto producto) async {
    Response response = await put('$url/updatec', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> updated(Producto producto, {File? planopdf}) async {
    try {
      Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/updated');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = userSession.sessionToken ?? '';

      // Añade el archivo PDF solo si se proporciona
      if (planopdf != null) {
        var stream = http.ByteStream(planopdf.openRead());
        var length = await planopdf.length();
        var multipartFile = http.MultipartFile('pdf', stream, length,
            filename: basename(planopdf.path));
        request.files.add(multipartFile);
      }

      // Añade los otros campos del producto
      request.fields['producto'] = json.encode(producto.toJson());

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      return ResponseApi.fromJson(json.decode(responseString));
    } catch (e) {
      print('Error en ProductoProvider.updated: $e');
      return ResponseApi(
        success: false,
        message: 'Error al actualizar el producto: $e',
      );
    }
  }

  Future<ResponseApi> liberar(Producto producto, File pdfFile) async {
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/updatedlib');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = userSession.sessionToken ?? '';

    // Añade el archivo PDF
    var stream = http.ByteStream(pdfFile.openRead());
    var length = await pdfFile.length();
    var multipartFile = http.MultipartFile('pdf', stream, length,
        filename: basename(pdfFile.path));
    request.files.add(multipartFile);

    // Añade los otros campos del producto
    request.fields['producto'] = json.encode(producto.toJson());

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    return ResponseApi.fromJson(json.decode(responseString));
  }

  Future<ResponseApi> updateds(Producto producto) async {
    Response response = await put('$url/updateds', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> rechazar(Producto producto) async {
    Response response =
        await put('$url/updatedrech', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> entregar(Producto producto) async {
    Response response =
    await put('$url/updatedent', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
  Future<ResponseApi> retrabajo(Producto producto) async {
    Response response =
        await put('$url/updatedret', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }


  Future<ResponseApi> libera(Producto producto, File pdfFile) async {
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/updatedlib');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = userSession.sessionToken ?? '';

    request.files.add(http.MultipartFile(
        'pdf', pdfFile.openRead(), await pdfFile.length(),
        filename: basename(pdfFile.path)));

    request.fields['product'] = json.encode(producto);
    final response = await request.send();
    final responseString = await response.stream.bytesToString();
    return ResponseApi.fromJson(json.decode(responseString));
  }

  Future<ResponseApi> deleted(String productoId) async {
    final response = await delete('$url/deleted/$productoId', headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<Stream?> update(
      Producto producto, List<File> images, productId) async {
    // Verifica si el ID del producto está definido y no es nulo o vacío
    if (producto.id == null || producto.id!.isEmpty) {
      print('El ID del producto no está definido o es vacío');
      // Puedes manejar este caso como desees, por ejemplo, lanzando una excepción o mostrando un mensaje de error.
      return null;
    }
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/updated');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = userSession.sessionToken ?? '';

    for (int i = 0; i < images.length; i++) {
      request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(images[i].openRead().cast()),
          await images[i].length(),
          filename: basename(images[i].path)));
    }

    request.fields['producto'] = json.encode(producto);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  Future<Stream> create(Producto producto, List<File> images) async {
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/producto/create');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = userSession.sessionToken ?? '';

    for (int i = 0; i < images.length; i++) {
      request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(images[i].openRead().cast()),
          await images[i].length(),
          filename: basename(images[i].path)));
    }

    request.fields['producto'] = json.encode(producto);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // para mostrar la lista por status
  Future<List<Producto>> findByStatus(String estatus) async {
    Response response = await get('$url/findByStatus/$estatus', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.sessionToken ?? ''
    });

    if (response.statusCode == 401) {
      Get.snackbar(
          'Petición denegada', 'Tu usuario no puede leer esta informacion');
      return [];
    }

    List<Producto> producto = Producto.fromJsonList(response.body);
    print('Productos recibidos del servidor: $producto');
    return producto;
  }

  Future<ResponseApi> edit(Producto producto) async {
    Response response = await put('$url/update', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> mat(Producto producto) async {
    Response response = await put('$url/updatem', producto.toJson(), headers: {
      //'Content-Type': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la informacion');
      return ResponseApi();
    }
    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No estas autorizado para actualizar los datos');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
// Función para obtener las total_ots
  Future<ResponseApi> getTotalOTs() async {
    Response response = await get('$url/countOTs', headers: {
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  // Función para obtener las lib_ots
  Future<ResponseApi> getEntOT() async {
    Response response = await get('$url/countOTsEnt', headers: {
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {

      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
  Future<ResponseApi> getLibOTs() async {
    Response response = await get('$url/countOTsTer', headers: {
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
  // Función para obtener los productos fabricados
  Future<ResponseApi> getlibProducts() async {
    Response response = await get('$url/countProducts', headers: {
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<ResponseApi> getEfecProducts() async {
    Response response = await get('$url/countProductsEfec', headers: {
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  Future<ResponseApi> getlibProductsrr() async {
    Response response = await get('$url/countProductsrr', headers: {
      'Authorization': userSession.sessionToken ?? ''
    });
    if (response.body == null) {
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
}
