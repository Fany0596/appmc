import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/pages/Generico/detalles/generico_detalles_page.dart';
import 'package:maquinados_correa/src/pages/Generico/genericoHome/generico_home_page.dart';
import 'package:maquinados_correa/src/pages/Generico/list/list_page.dart';
import 'package:maquinados_correa/src/pages/calidad/comprasHome/calidad_home_page.dart';
import 'package:maquinados_correa/src/pages/calidad/orders/liberacion/liberacion_page.dart';
import 'package:maquinados_correa/src/pages/calidad/orders/list/calidad_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/compras/comprasHome/compras_home_page.dart';
import 'package:maquinados_correa/src/pages/compras/list/compras_oc_list_page.dart';
import 'package:maquinados_correa/src/pages/compras/newProveedor/new_proveedor_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/create_product_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/oc/create_oc_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/product/compras_product_page.dart';
import 'package:maquinados_correa/src/pages/compras/tabla/compras_tab_page.dart';
import 'package:maquinados_correa/src/pages/compras/update/product/update_product_page.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/detalles_produccion/detalles_produccion_page.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/ot/produccion_ot_page.dart';
import 'package:maquinados_correa/src/pages/produccion/produccionHome/produccion_home_page.dart';
import 'package:maquinados_correa/src/pages/produccion/tabla/entregado/entrega_page.dart';
import 'package:maquinados_correa/src/pages/produccion/tabla/produccion_tab_page.dart';
import 'package:maquinados_correa/src/pages/profile/info/profile_info_page.dart';
import 'package:maquinados_correa/src/pages/profile/info/update/profile_update_page.dart';
import 'package:maquinados_correa/src/pages/tym/list/tiempos/tiempos_page.dart';
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/tym/newOperador/new_operador_page.dart';
import 'package:maquinados_correa/src/pages/login/login_page.dart';
import 'package:maquinados_correa/src/pages/registro/registro_page.dart';
import 'package:maquinados_correa/src/pages/roles/roles_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/list/compras_page.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/list/produccion_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/tym/tabla/tym_tab_page.dart';
import 'package:maquinados_correa/src/pages/tym/tymHome/tym_home_page.dart';
import 'package:maquinados_correa/src/pages/ventas/newClient/new_client_page.dart';
import 'package:maquinados_correa/src/pages/ventas/newVendedor/new_vendedor_page.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/detalles/detalles_page.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/list/ventas_oc_list_page.dart';
import 'package:maquinados_correa/src/pages/ventas/tabla/ventas_tab_page.dart';
import 'package:maquinados_correa/src/pages/ventas/update/price/pricem_producto_page.dart';
import 'package:maquinados_correa/src/pages/ventas/update/update/update_producto_page.dart';
import 'package:maquinados_correa/src/pages/ventas/ventasHome/ventas_home_page.dart';
import 'package:file_picker/file_picker.dart';

User userSession = User.fromJson(GetStorage().read('user') ??{});// para ya o iniciar el login cuando se inicio sesion

void main() async {
  await GetStorage.init();
  FilePicker.platform = FilePicker.platform;
  runApp(MyApp());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('El token de sesion del usuario: ${userSession.sessionToken}');
  }

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Maquinados Correa',
      debugShowCheckedModeBanner: false,
      initialRoute: userSession.id != null ?  userSession.roles!.length > 1 ? '/roles' : 'ventas/home' : '/', //valida si ya se a iniciado sesion para enviar a home o de lo contrario a login, esta linea sustituye al if (? es para decir "si" y : para decir "de lo contrario")
      getPages:[
        GetPage(name: '/', page:()=> LoginPage()),
        GetPage(name: '/registro', page:()=> RegisterPage()),
        GetPage(name: '/roles', page:()=> RolesPage()),
        GetPage(name: '/compras/orders/list', page:()=> ComprasDetallesPage()),
        GetPage(name: '/compras/list', page:()=> ComprasOcListPage()),
        GetPage(name: '/produccion/orders/list', page:()=> ProduccionOtListPage()),
        GetPage(name: '/tym/list', page:()=> TymOtListPage()),
        GetPage(name: '/tym/list/tiempos', page:()=> TiemposPage()),
        GetPage(name: '/generico/list', page:()=> ListPage()),
        GetPage(name: '/generico/detalles', page:()=>  GenericoDetallesPage()),
        GetPage(name: '/ventas/orders/list', page:()=> VentasOcListPage()),
        GetPage(name: '/ventas/orders/detalles', page:()=> VentasDetallesPage()),
        GetPage(name: '/compras/orders/product', page:()=> ComprasProductPage()),
        GetPage(name: '/produccion/orders/detalles_produccion', page:()=> ProduccionDetallesPage()),
        GetPage(name: '/produccion/tabla', page:()=> ProduccionTabPage()),
        GetPage(name: '/produccion/tabla/entrega', page:()=> EntregaPage()),
        GetPage(name: '/compras/tabla', page:()=> ComprasTabPage()),
        GetPage(name: '/ventas/tabla', page:()=> VentasTabPage()),
        GetPage(name: '/tym/tabla', page:()=> TymTabPage()),
        GetPage(name: '/produccion/orders/ot', page:()=> ProduccionOtPage()),
        GetPage(name: '/ventas/home', page:()=> VentasHomePage()),
        GetPage(name: '/tym/home', page:()=> TymHomePage()),
        GetPage(name: '/produccion/home', page:()=> ProduccionHomePage()),
        GetPage(name: '/generico/home', page:()=> GenericoHomePage()),
        GetPage(name: '/compras/home', page:()=> ComprasHomePage()),
        GetPage(name: '/calidad/home', page:()=> CalidadHomePage()),
        GetPage(name: '/ventas/newClient', page:()=> NewClientPage()),
        GetPage(name: '/compras/newProveedor', page:()=> NewProveedorPage()),
        GetPage(name: '/ventas/newVendedor', page:()=> VendedoresPage()),
        GetPage(name: '/ventas/update/update', page:()=> UpdateProductoPage()),
        GetPage(name: '/ventas/update/price', page:()=> PriceProductoPage()),
        GetPage(name: '/tym/newOperador', page:()=> OperadorPage()),
        GetPage(name: '/calidad/orders/list', page:()=> CalidadOtListPage()),
        GetPage(name: '/calidad/orders/liberacion', page:()=> LiberacionPage()),
        GetPage(name: '/compras/orders/new_order/oc', page:()=> OcPage()),
        GetPage(name: '/compras/orders/new_order', page:()=> ProductPage()),
        GetPage(name: '/compras/update/product', page:()=> UpdateProductPage()),
        GetPage(name: '/profile/info', page:()=> ProfileInfoPage()),
        GetPage(name: '/profile/info/update', page:()=> ProfileUpdatePage())
      ],
      theme: ThemeData(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme(
            primary: Colors.black,
            secondary: Colors.blueAccent,
            brightness: Brightness.light,
            onBackground: Colors.grey,
            onPrimary: Colors.black,
            surface: Colors.grey,
            onSecondary: Colors.grey,
            onSurface: Colors.black,
            background: Colors.white,
            error: Colors.grey,
            onError: Colors.grey,

          )
      ),
      navigatorKey: Get.key,

    );
  }
}



