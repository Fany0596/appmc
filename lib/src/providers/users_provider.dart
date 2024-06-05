import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:http/http.dart' as http;

class UsersProvider extends GetConnect {

  String  url = Environment.API_URL + "api/users";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<Response> create(User user) async {
    Response response = await post(
      '$url/create',
      user.toJson(),
      //contentType: 'application/json; charset=UTF-8',
        headers: {
          'Content-Type': 'application/json'
        }
    );
    return response;
  }
// actualizar los datos sin imagen
  Future<ResponseApi> update(User user) async {
    Response response = await put(
      '$url/updateWithoutImage',
      user.toJson(),
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
  // actualiza los datos con imagen
  Future<Stream> updateWithImage(User user, File image) async {
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/users/update');
    final request = http.MultipartRequest('PUT', uri);
    request.headers ['Authorization'] = userSession.sessionToken ?? '';
    request.files.add(http.MultipartFile(
        'image',
        http.ByteStream(image.openRead().cast()),
        await image.length(),
        filename: basename(image.path)
    ));
    request.fields['user'] = json.encode(user);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }
// almacena la imagen en la base de datos
  Future<Stream> createWithImage(User user, File image) async{
    Uri uri = Uri.https(Environment.API_URL_OLD, '/api/users/createWithImage');
    //Uri uri = Uri.http(Environment.API_URL, 'api/users/createWithImage');
    print('Uri ${uri}');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path)

    ));
  request.fields['user'] = json.encode(user);
  final response = await request.send();
  return response.stream.transform(utf8.decoder);
  }
//
  Future<ResponseApi> login(String email, String password) async {
    Response response = await post(
      '$url/login',
      {// recibe los datos de inicio de sesion
        'email': email,
        'password':password
      },
      contentType: 'application/json; charset=UTF-8',
    );

    if(response.body == null){
      Get.snackbar('Error','No se pudo ejecutar la peticion');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
}
