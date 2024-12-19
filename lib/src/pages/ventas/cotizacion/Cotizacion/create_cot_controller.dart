import 'dart:convert';
import 'dart:io';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/response_api.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/providers/client_provider.dart';
import 'package:maquinados_correa/src/providers/cotizacion_provider.dart';
import 'package:maquinados_correa/src/providers/material_provider.dart';
import 'package:maquinados_correa/src/providers/producto_provider.dart';
import 'package:maquinados_correa/src/providers/vendedor_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class CombinedController extends GetxController {
  final ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  // Controladores de texto para cotización
  TextEditingController numberController = TextEditingController();
  TextEditingController entController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController condicionesController = TextEditingController();
  TextEditingController descuentoController = TextEditingController();
  TextEditingController reqController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController garantController = TextEditingController();
  TextEditingController bancController = TextEditingController();
  TextEditingController agreg1Controller = TextEditingController();
  TextEditingController agreg2Controller = TextEditingController();
  TextEditingController agreg3Controller = TextEditingController();
  TextEditingController agreg4Controller = TextEditingController();
  TextEditingController coment1Controller = TextEditingController();
  TextEditingController coment2Controller = TextEditingController();
  TextEditingController coment3Controller = TextEditingController();


  // Controladores de texto para producto
  TextEditingController articuloController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  // Variables observables
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  var idVendedores = ''.obs;
  var idClientes = ''.obs;
  String? prevNumb; // Variable para almacenar el último número de cotización registrado
  String? newNumb;
  var idCotizaciones = ''.obs;
  Rx<String> selectedCondition = Rx<String>('');
  RxList<ProductFormData> productForms = <ProductFormData>[].obs;
  var tieneGarantia = false.obs;
  var tieneBanc = false.obs;
  var tieneAgreg1 = false.obs;
  var tieneAgreg2 = false.obs;
  var tieneAgreg3 = false.obs;
  var tieneAgreg4 = false.obs;
  var tieneComent1 = false.obs;
  var tieneComent2 = false.obs;
  var tieneComent3 = false.obs;


  // Listas
  List<Vendedores> vendedores = <Vendedores>[].obs;
  List<Clientes> clientes = <Clientes>[].obs;
  List<Materiales> materiales = <Materiales>[].obs;
  List<Producto> productosPendientes = <Producto>[].obs;

  // Providers
  VendedoresProvider vendedoresProvider = VendedoresProvider();
  ClientesProvider clientesProvider = ClientesProvider();
  CotizacionProvider cotizacionProvider = CotizacionProvider();
  ProductoProvider productoProvider = ProductoProvider();
  MaterialesProvider materialesProvider = MaterialesProvider();

  @override
  void onInit() {
    super.onInit();
    getNextQuoteNumber();
    getVendedores();
    getClientes();
    precioController.addListener(updateTotal);
    cantidadController.addListener(updateTotal);
    addProductForm();
  }

  void addProductForm() {
    ProductFormData newForm = ProductFormData();
    newForm.precioController.addListener(newForm.updateTotal);
    newForm.cantidadController.addListener(newForm.updateTotal);
    productForms.add(newForm);
    update();
  }
  void removeProductForm(int index) {
    if (productForms.length > 1) {
      productForms[index].dispose();
      productForms.removeAt(index);
      update();
    }
  }


  void clearProductForms() {
    for (var form in productForms) {
      form.descrController.clear();
      form.precioController.clear();
      form.cantidadController.clear();
      form.totalController.clear();
    }
  }

  @override
  void onClose() {
    for (var form in productForms) {
      form.dispose();
    }
    super.onClose();
  }
  void getNextQuoteNumber() async {
    List<Cotizacion> cotizaciones = await cotizacionProvider.getAll();
    String yearSuffix = DateTime.now().year.toString().substring(2); // Últimos dos dígitos del año actual
    String newNumb;

    if (cotizaciones.isNotEmpty) {
      // Filtra y procesa todas las cotizaciones del año actual
      List<int> quoteNumbers = [];

      for (var cotizacion in cotizaciones) {
        String quoteNumber = cotizacion.number ?? "";

        // Expresión regular mejorada para capturar ambos formatos
        RegExp formatRegex = RegExp(r'COT-(\d+)(?:-(\d{2}))?');

        if (formatRegex.hasMatch(quoteNumber)) {
          Match match = formatRegex.firstMatch(quoteNumber)!;
          String numberPart = match.group(1)!;
          String? yearPart = match.group(2);

          // Solo procesa números del año actual
          if (yearPart == null || yearPart == yearSuffix) {
            try {
              int number = int.parse(numberPart);
              quoteNumbers.add(number);
            } catch (e) {
              print('Error parsing number: $numberPart');
            }
          }
        }
      }

      // Encuentra el número más alto
      int nextNumber;
      if (quoteNumbers.isNotEmpty) {
        quoteNumbers.sort(); // Ordena los números
        nextNumber = quoteNumbers.last + 1;
      } else {
        nextNumber = 1;
      }

      // Formatea el nuevo número
      String formattedNumber = nextNumber.toString().padLeft(2, '0');
      newNumb = 'COT-$formattedNumber-$yearSuffix';

      print('Números encontrados: $quoteNumbers');
      print('Siguiente número: $nextNumber');
    } else {
      newNumb = 'COT-01-$yearSuffix';
    }

    print('Nuevo número de cotización: $newNumb');
    numberController.text = newNumb;
    update();
  }
  void getVendedores() async {
    var result = await vendedoresProvider.getAll();
    vendedores.clear();
    vendedores.addAll(result);
  }

  void getClientes() async {
    var result = await clientesProvider.getAll();
    clientes.clear();
    clientes.addAll(result);
  }

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;

    // Actualiza el valor del controlador de "Total"
    totalController.text = total.toStringAsFixed(2);
  }

  void agregarProducto(BuildContext context) {
    for (int i = 0; i < productForms.length; i++) {
      ProductFormData form = productForms[i];
      String descr = form.descrController.text;
      String precio = form.precioController.text;
      String cantidad = form.cantidadController.text;

      if (isValidProductForm(descr, precio, cantidad)) {
        try {
          double precioDouble = double.parse(precio);
          double cantidadDouble = double.parse(cantidad);
          double total = precioDouble * cantidadDouble;

          Producto producto = Producto(
            descr: descr,
            precio: precioDouble,
            cantidad: cantidadDouble,
            total: total,
            idCotizaciones: idCotizaciones.value,
          );

          productosPendientes.add(producto);
        } catch (e) {
          print('Error al procesar el producto $i: $e'); // Para depuración
          Get.snackbar('Error', 'Ocurrió un error al procesar el producto $i',
              backgroundColor: Colors.red, colorText: Colors.white);
          return; // Salir de la función si hay un error
        }
      } else {
        return; // Salir de la función si la validación falla
      }
    }
    // Limpiar todos los formularios existentes
    for (var form in productForms) {
      form.dispose();
    }
    productForms.clear();

    // Agregar un solo formulario limpio
    addProductForm();
    // Si llegamos aquí, todos los productos se agregaron correctamente
    //clearProductForms();
    update();
    Get.snackbar('Productos agregados', 'Los productos se han agregado a la lista',
        backgroundColor: Colors.green, colorText: Colors.white);
  }
  bool isValidProductForm(String descr, String precio, String cantidad) {
    if (descr.isEmpty || precio.isEmpty || cantidad.isEmpty) {
      Get.snackbar(
        'Formulario no válido',
        'Por favor, llene todos los campos del producto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (double.tryParse(precio) == null || double.tryParse(cantidad) == null) {
      Get.snackbar(
        'Formulario no válido',
        'El precio y la cantidad deben ser números válidos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  void guardarTodosLosProductos(BuildContext context) async {
    if (productosPendientes.isEmpty) {
      Get.snackbar('Error', 'No hay productos para guardar',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Guardando productos...');

    for (var producto in productosPendientes) {
      List<File> images = [];
      Stream stream = await productoProvider.create(producto, images);
      await for (var res in stream) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        if (responseApi.success != true) {
          progressDialog.close();
          Get.snackbar(
              'Error', 'No se pudo guardar el producto: ${producto.articulo}',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }
    }

    progressDialog.close();
    Get.snackbar('Éxito', 'Todos los productos han sido guardados',
        backgroundColor: Colors.green, colorText: Colors.white);
    productosPendientes.clear();
    clearForm2();
  }

  void removeProducto(int index) {
    productosPendientes.removeAt(index);
    update();
  }

  void guardarCotizacionYProductos(BuildContext context) async {
    if (!isValidForms()) {
      Get.snackbar('Error', 'Por favor, complete todos los campos requeridos',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Guardando cotización y productos...');

    try {
      // Crear objeto Cotizacion
      Cotizacion cotizacion = Cotizacion(
          number: numberController.text,
          ent: entController.text,
          fecha: fechaController.text,
          nombre: nombreController.text,
          correo: correoController.text,
          req: reqController.text,
          condiciones: condicionesController.text,
          descuento: descuentoController.text,
          garant: tieneGarantia.value ? 'si' : 'no',
          banc: tieneBanc.value ? 'si' : 'no',
          agreg1: tieneAgreg1.value ? 'si' : 'no',
          agreg2: tieneAgreg2.value ? 'si' : 'no',
          agreg3: tieneAgreg3.value ? 'si' : 'no',
          agreg4: tieneAgreg4.value ? 'si' : 'no',
          coment1: tieneComent1.value ? 'si' : 'no',
          coment2: tieneComent2.value ? 'si' : 'no',
          coment3: tieneComent3.value ? 'si' : 'no',
          telefono: telefonoController.text,
          idVendedores: idVendedores.value,
          idClientes: idClientes.value
      );

      // Guardar la cotización
      List<File> images = [];
      ResponseApi cotizacionResponse = await cotizacionProvider.create(cotizacion, images).then((stream) => stream.first).then((res) => ResponseApi.fromJson(json.decode(res)));

      if (cotizacionResponse.success == true) {
        int cotizacionId = int.parse(cotizacionResponse.data['id_cotizacion'].toString());
        print('ID de cotización generado: $cotizacionId');

        // Si la cotización se guardó exitosamente, guarda los productos
        for (var producto in productosPendientes) {
          producto.idCotizaciones = cotizacionId.toString();
          ResponseApi productoResponse = await productoProvider.create(producto, images).then((stream) => stream.first).then((res) => ResponseApi.fromJson(json.decode(res)));

          if (productoResponse.success != true) {
            throw Exception('Error al guardar producto: ${productoResponse.message}');
          }
        }

        progressDialog.close();
        Get.snackbar('Éxito', 'Cotización y productos guardados correctamente',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Limpiar formularios y lista de productos pendientes
        clearForm();
        productosPendientes.clear();
        goToHome();
        update();
      } else {
        throw Exception('Error al guardar la cotización: ${cotizacionResponse.message}');
      }
    } catch (e) {
      progressDialog.close();
      Get.snackbar('Error', 'No se pudo guardar la cotización y/o productos: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  bool isValidForms() {
    return numberController.text.isNotEmpty &&
        fechaController.text.isNotEmpty &&
        condicionesController.text.isNotEmpty &&
        idVendedores.value.isNotEmpty &&
        idClientes.value.isNotEmpty &&
        productosPendientes.isNotEmpty;
  }

  void clearForm() {
    numberController.clear();
    fechaController.clear();
    nombreController.clear();
    correoController.clear();
    reqController.clear();
    condicionesController.clear();
    descuentoController.clear();
    telefonoController.clear();
    idVendedores.value = '';
    idClientes.value = '';
    articuloController.clear();
    descrController.clear();
    precioController.clear();
    cantidadController.clear();
    totalController.clear();
    for (var form in productForms) {
      form.dispose();
    }
    productForms.clear();
    addProductForm(); // Agregar un formulario inicial limpio

    update();
  }

  void clearForm2() {
    articuloController.text = '';
    descrController.text = '';
    precioController.text = '';
    cantidadController.text = '';
    totalController.text = '';
    update();
  }
  void reloadPage() {
    update(); // Actualizar el controlador
  }
  void goToPerfilPage(){
    Get.toNamed('/profile/info');
  }
  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }
  void goToNewVendedorPage(){
    Get.toNamed('/ventas/newVendedor');
  }
  void goToHome() {  // Método que navega a la pagina de inicio de ventas
    Get.offNamedUntil('/ventas/home', (route) => false);
  }
  void goToNewClientePage(){
    Get.toNamed('/ventas/newClient');
  }
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false); //Elimina el historial de las pantallas y regresa al login
  }
}
class ProductFormData {
  final TextEditingController descrController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  void updateTotal() {
    double precio = double.tryParse(precioController.text) ?? 0;
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double total = precio * cantidad;
    totalController.text = total.toStringAsFixed(2);
  }

  void dispose() {
    descrController.dispose();
    precioController.dispose();
    cantidadController.dispose();
    totalController.dispose();
  }
}