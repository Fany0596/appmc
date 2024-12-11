import 'package:flutter/material.dart';  // Importa la biblioteca para construit la interfaz del usuario
import 'package:get/get.dart';  // Importa la biblioteca GetX para la gestión del estado y navegación
import 'package:maquinados_correa/src/models/producto.dart';  // Importa el modelo producto
import 'package:maquinados_correa/src/models/response_api.dart';  // Importa el modelo de la respuesta de la API
import 'package:maquinados_correa/src/providers/producto_provider.dart';  // Importa el provedor para consultas relacionadas con el producto
import 'package:sn_progress_dialog/progress_dialog.dart';  // Importa el diálogo de progreso visual
import 'dart:io';  // Importa la biblioteca para trabajar con archivos
import 'package:file_picker/file_picker.dart';  // Importa la biblioteca para seleccionar archivos

class LiberacionController extends GetxController {  // Controlador que maneja la lógica para la determinación de los productos
  Producto? producto;  // Variable que almacena el producto actual
  File? pdfFile;  // Archivo PDF seleccionado
  final Rx<String> pdfFileName = ''.obs;  // Nombre del archivo PDF seleccionado, reactivo para actualizaciones automáticas

  @override
  void onInit() { // Método que se ejecuta cuando el controlador se inicializa
    super.onInit();
    print('Argumentos recibidos: ${Get.arguments}'); // Imprime los argumentos recibidos en el controlador
    producto = Producto.fromJson(Get.arguments['producto']);  // Asigna el producto recibido desde los argumentos
  }

  ProductoProvider productoProvider = ProductoProvider();  // Provedor que maneja las operaciones (consultas) de producto

  void rechazado(BuildContext context) async {  // Metodo para rechazar el producto
    String productId = producto?.id ?? '';  // Obtiene el ID del producto o un valor vacío si es nulo
    print('ID del producto a actualizar: $productId'); // Imprime el ID del producto
    ProgressDialog progressDialog = ProgressDialog(context: context);  // Crea un dialogo de progreso

    if (isValidForms()) { // Verifica que los formularios sean válidos
      Producto myproducto = Producto(  // Crea una instancia de producto con los valores especificos para rechazo
        id: producto!.id, // Para id asiga el ID de a variable Producto
        estatus: 'RECHAZADO',  // Para el estatus se asigna rechazdo
        operador: '',  // Para el operador se asigna un valor vacio
        operacion: '',  // Para la operacion se asigna un valor vacio
        rechazo: 'si',  // Para la opcion de rechazo se asigna un si
        fecharcrt: DateTime.now().toString(),  // Paara la fecha se asigna la fecha actual
      );

      try { // Bloque try-catch para manejar errores
        ProgressDialog progressDialog = ProgressDialog(context: context); // Muestra un diálogo de progrso mientras se realiza la actualización
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        ResponseApi responseApi = await productoProvider.rechazar(myproducto); // Realizar la solicitud de actualización al productoProvider

        progressDialog.close();  // Cierra el diálogo de progreso

        if (responseApi.success == true) { // En caso de éxito
          Get.snackbar(  // Muestra un mensaje exitoso
            'Éxito',
            'Producto actualizado correctamente',
            backgroundColor: Colors.green,  // Color de fondo del mensaje
            colorText: Colors.white,  // Color de texto
          );
        }
      } catch (e) {  // En caso de fallo
        print('Error al actualizar el producto: $e'); // Imprime el mensaje de error
        Get.snackbar(  // Muestra el mensaje de error
          'Ocurrió un error al actualizar el producto',
          'Verifique los campos',
          backgroundColor: Colors.red, // Color de fondo del mensaje
          colorText: Colors.white,  // Color del texto
        );
      }
    }
  }

  void retrabajo(BuildContext context) async {  // Método para poner el producto en estado de retrabajo
    String productId = producto?.id ?? '';  // Obtiene el ID del producto o proporciona un valor nulo
    print('ID del producto a actualizar: $productId');  // Imprime el ID del producto a actualizar
    ProgressDialog progressDialog = ProgressDialog(context: context);  // Crea un dialogo de progreso

    if (isValidForms()) {  // Valida que los formularios sean validos
      Producto myproducto = Producto(  // Crea una instancia del producto con los valores especificos para retrabajo
        id: producto!.id,  // Para el id se asigna el ID de la variable Producto
        estatus: 'RETRABAJO',  // Para el estatus se asigna el de retrabajo
        operador: '',  // Para el operador se asigna un campo vacio
        operacion: '',  // Para la operacion se asigna un campo vacio
        retrabajo: 'si',  // Para la opcion de retrabajo se asigna un si
        fecharcrt: DateTime.now().toString(), // Para la fecha del retrabajo se asigna la fecha actual
      );
      //Mostrar mensaje de éxito

      try {  // Bloque try-catch para manejar errores
        ProgressDialog progressDialog = ProgressDialog(context: context);  // Muestra un diálogo de progreso
        progressDialog.show(max: 100, msg: 'Actualizando producto...');

        ResponseApi responseApi = await productoProvider.retrabajo(myproducto);  // Llama al método retrabajo del producto provider

        progressDialog.close();  // Cierra el diálogo de progreso

        if (responseApi.success == true) {  // Si la respuesta es exitosa
          Get.snackbar(
            'Producto actualizado correctamente',' Se ha liberado el producto', // Muestra un mensaje de éxito
            backgroundColor: Colors.green,  // Color de fondo del mensaje
            colorText: Colors.white,  // Color del texto
          );
        }
      } catch (e) {  // En caso de error
        print('Error al actualizar el producto: $e'); // Imprime el mensaje de error
        Get.snackbar(
          'Ocurrió un error al actualizar el producto',  // Muestra el mensaje de error
          'Verifique los campos',
          backgroundColor: Colors.red,  // Color de fondo del mensaje
          colorText: Colors.white,  // Color del texto
        );
      }
    }
  }

  bool isValidForms() {  // Verifica que los campos del formulario sean válidos
    if (producto!.id!.isEmpty) { // Muestra un mensaje de error si el ID del producto no es valido
      Get.snackbar(
        'Formulario no valido',
        'Llene todos los campos',
        backgroundColor: Colors.red, // Color de fondo del mensaje
        colorText: Colors.white, // Color del texto
      );
      return false; // Retorna falso, indicando que el formulario no es valido
    }
    return true;  // Retorna verdadero si el formulario es válido
  }

  void liberar(BuildContext context) async {  // Método para cambiar el estatus del producto a 'LIBERADO'
    String productId = producto?.id ?? ''; // Obtiene el ID del producto o un valor vacío si es nulo
    print('ID del producto a actualizar: $productId');  // Imprime el ID del producto que se va a actualizar
    ProgressDialog progressDialog = ProgressDialog(context: context);  // Crea una instancia de ProgressDialog para mostrar el estado de la operación

    if (isValidFormss()) {  // Verifica si el formulario es válido
      Producto myproducto = Producto(  // Crea una nueva instancia de Producto con los valores especificos para liberado
        id: producto!.id,  // Para el id se asigna el ID de la variable producto
        estatus: 'LIBERADO', // Para estatus se asiga en 'LIBERADO'
        operador: '', // Para el operador se asigna un campo vacio
        operacion: '',  // Para la operación se asigna un campo vacio
        fechalib: DateTime.now().toString(),  // Para la fecha de liberación se asigna la fecha actual
      );
      if (pdfFile == null) {  // Verifica si se ha seleccionado un archivo PDF
        Get.snackbar('Error', 'Por favor, selecciona el reporte dimensional', // Muestra un mensaje de error si no se ha seleccionado un PDF
          backgroundColor: Colors.red,  // Color de fondo del mensaje
          colorText: Colors.white,);  // Color de letra
        return;
      }
      progressDialog.show(max: 100, msg: 'Espere un momento...');  // Muestra un dialogo de progreso

      try {
        ResponseApi responseApi =
            await productoProvider.liberar(myproducto, pdfFile!);  // Llama al método liberar del productoProvider con el archivo PDF
        progressDialog.close();  // Cierra el diálogo de progreso

        if (responseApi.success == true) {  // Si la respuesta es exitosa
          Get.snackbar(  // Muestra un mensaje de éxito
            'Producto liberado exitosamente',
            '',
            backgroundColor: Colors.green,  // Color de fondo del mensaje
            colorText: Colors.white,  // Color del texto
          );
          goToHome();  // Navega a la pantalla de inicio
        }
      } catch (e) { // En caso de error
        progressDialog.close();  // Cierra el dialogro de progreso
        Get.snackbar(  // Muestra el mensaje de error
          'Error',
          'No se pudo crear el producto: ${e.toString()}', // Muestra el tipo de error
          backgroundColor: Colors.red,  // Color de fondo del mensaje
          colorText: Colors.white,  // Color del texto
        );
      }
    }
  }

  bool isValidFormss() {  // Verifica que los campos del formulario sean validos
    if (producto!.id!.isEmpty) {  // Si el Id no es valido
      Get.snackbar(  // Muestra un mensaje de error
        'Formulario no valido',
        'Llene todos los campos',
        backgroundColor: Colors.red,  // Color de fondo del mensaje
        colorText: Colors.white,  // Color de texto
      );
      return false; // Retorna falso, indicando que el formulario no es valido
    }
    if (pdfFile == null) { // Si el archivo PDF esta vacio
      Get.snackbar(  // Muestra un mensaje de error
          'Formulario no válido', 'Selecciona un archivo PDF para el producto',
        backgroundColor: Colors.red,  // Color de fondo del mensaje
        colorText: Colors.white,  // Color de texto
      );
      return false;  // Retorna falso, indicando que el formulario no es valido
    }
    return true;  // Retorna verdadero si el formulario es válido
  }

  Future selectPDF() async {  // Método para seleccionar el archivo PDF desde el sistema
    FilePickerResult? result = await FilePicker.platform.pickFiles(  // Muestra el selector de archivos y permite seleccionar un PDF
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Extensión del archivo admitido
    );

    if (result != null) { // Si se selecciona un archivo
      pdfFile = File(result.files.single.path!);  // Se asigna a pdfFile
      pdfFileName.value =
          result.files.single.name; // Actualiza el nombre del archivo
      update();  // Actualiza la interfaz
    }
  }

  void goToHome() {  // Método que navega a la pagina de inicio de calidad
    Get.offNamedUntil('/calidad/home', (route) => false);
  }
}
