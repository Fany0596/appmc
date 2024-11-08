import 'dart:convert';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/tiempo.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/environment/environment.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class TiempoProvider extends GetConnect {
  String  url = Environment.API_URL + "api/tiempo";
  String  urll = Environment.API_URL + "api";

  User userSession = User.fromJson(GetStorage().read('user') ?? {});


  Future<ResponseApi> create(Tiempo tiempo) async {
    Response response = await post(
        '$url/create',
        tiempo.toJson(),
        //contentType: 'application/json; charset=UTF-8',
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : userSession.sessionToken ?? ''
        }
    );
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }


  Future<List<Tiempo>> getTiemposByProductId(String productoId) async {
    try {
      final response = await http.get(
        Uri.parse('$urll/tiempo/getByProductId/$productoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] is List) {
          return (decodedResponse['data'] as List)
              .map((json) => Tiempo.fromJson(json))
              .toList();
        } else {
          throw Exception('Unexpected response format or no data');
        }
      } else {
        throw Exception('Failed to load tiempos for producto');
      }
    } catch (e) {
      print('Failed to connect to server: $e');
      throw e;
    }
  }
  Future<bool> hasInitialRecord(String productoId, String proceso) async {
    try {
      final response = await http.get(
        Uri.parse('$urll/tiempo/hasInitialRecord/$productoId/$proceso'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['hasInitialRecord'] ?? false;
      } else {
        throw Exception('Failed to check initial record');
      }
    } catch (e) {
      print('Failed to connect to server: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>> getLastStateByProductoAndProceso(String productoId, String proceso) async {
    try {
      final response = await http.get(
        Uri.parse('$urll/tiempo/lastState/$productoId/$proceso'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'lastState': data['estado'],
          'hasRecords': data['hasRecords'],
        };
      } else {
        throw Exception('Failed to get last state');
      }
    } catch (e) {
      print('Failed to connect to server: $e');
      return { 'lastState': null, 'hasRecords': false };
    }
  }
  Future<Map<String, dynamic>> getLastRecord(String productoId) async {
    try {
      print('Obteniendo último registro para productoId: $productoId'); // Imprimir el ID del producto
      final response = await http.get(
        Uri.parse('$urll/tiempo/lastRecord/$productoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        },
      );

      print('Estado de respuesta: ${response.statusCode}'); // Imprimir el estado de la respuesta

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Datos recibidos: $jsonData'); // Imprimir los datos recibidos

        // Verifica que `success` sea true y que haya datos en `data`
        if (jsonData['success'] == true && jsonData['data'].isNotEmpty) {
          final data = jsonData['data'][0]; // Acceder al primer elemento de `data`

          return {
            'proceso': data['proceso'],
            /*'idOperador': data['idoperador'], // Ten en cuenta la clave correcta
            'estado': data['estado'],*/
            'idOperador': data['idOperador']?.toString() ?? '', // Asegúrate de que sea string
            'estado': data['estado'] ?? '',
            'success': true
          };
        } else {
          print('No se encontraron registros o éxito es false.');
          return {
            'proceso': '',
            'idOperador': '',
            'estado': '',
            'success': false
          };
        }
      } else {
        print('Error: ${response.reasonPhrase}'); // Imprimir el mensaje de error en caso de respuesta no exitosa
        return {
          'proceso': '',
          'idOperador': '',
          'estado': '',
          'success': false
        };
      }
    } catch (e) {
      print('Error al obtener último registro: $e');
      return {
        'proceso': '',
        'idOperador': '',
        'estado': '',
        'success': false
      };
    }
  }
  Future<List<Tiempo>> getTiempByProductId(String productoId) async {
    Response response = await get(
        '$url/getByProductId/$productoId',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken ?? ''
        }
    );

    if (response.statusCode == 401) {
      Get.snackbar('Petición denegada', 'Tu usuario no puede leer esta información');
      return [];
    }

    List<Tiempo> tiempos = Tiempo.fromJsonList(response.body);
    return tiempos;
  }
}

