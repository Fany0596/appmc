import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maquinados_correa/src/models/user.dart';
import 'package:maquinados_correa/src/pages/calidad/orders/list/calidad_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/compras/comprasHome/compras_home_page.dart';
import 'package:maquinados_correa/src/pages/compras/list/compras_oc_list_page.dart';
import 'package:maquinados_correa/src/pages/compras/newProveedor/new_proveedor_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/create_product_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/new_order/oc/create_oc_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/product/compras_product_page.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/detalles_produccion/detalles_produccion_page.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/ot/produccion_ot_page.dart';
import 'package:maquinados_correa/src/pages/produccion/produccionHome/produccion_home_page.dart';
import 'package:maquinados_correa/src/pages/produccion/tabla/produccion_tab_page.dart';
import 'package:maquinados_correa/src/pages/profile/info/profile_info_page.dart';
import 'package:maquinados_correa/src/pages/profile/info/update/profile_update_page.dart';
import 'package:maquinados_correa/src/pages/tym/orders/list/tym_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/home/home_page.dart';
import 'package:maquinados_correa/src/pages/login/login_page.dart';
import 'package:maquinados_correa/src/pages/registro/registro_page.dart';
import 'package:maquinados_correa/src/pages/roles/roles_page.dart';
import 'package:maquinados_correa/src/pages/compras/orders/list/compras_page.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/list/produccion_ot_list_page.dart';
import 'package:maquinados_correa/src/pages/ventas/newClient/new_client_page.dart';
import 'package:maquinados_correa/src/pages/ventas/newVendedor/new_vendedor_page.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/detalles/detalles_page.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/list/ventas_oc_list_page.dart';
import 'package:maquinados_correa/src/pages/ventas/tabla/ventas_tab_page.dart';
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
        GetPage(name: '/home', page:()=> HomePage()),
        GetPage(name: '/roles', page:()=> RolesPage()),
        GetPage(name: '/compras/orders/list', page:()=> ComprasDetallesPage()),
        GetPage(name: '/compras/list', page:()=> ComprasOcListPage()),
        GetPage(name: '/produccion/orders/list', page:()=> ProduccionOtListPage()),
        GetPage(name: '/ventas/orders/list', page:()=> VentasOcListPage()),
        GetPage(name: '/ventas/orders/detalles', page:()=> VentasDetallesPage()),
        GetPage(name: '/compras/orders/product', page:()=> ComprasProductPage()),
        GetPage(name: '/produccion/orders/detalles_produccion', page:()=> ProduccionDetallesPage()),
        GetPage(name: '/produccion/tabla', page:()=> ProduccionTabPage()),
        GetPage(name: '/ventas/tabla', page:()=> VentasTabPage()),
        GetPage(name: '/produccion/orders/ot', page:()=> ProduccionOtPage()),
        GetPage(name: '/ventas/home', page:()=> VentasHomePage()),
        GetPage(name: '/produccion/home', page:()=> ProduccionHomePage()),
        GetPage(name: '/compras/home', page:()=> ComprasHomePage()),
        GetPage(name: '/ventas/newClient', page:()=> NewClientPage()),
        GetPage(name: '/compras/newProveedor', page:()=> NewProveedorPage()),
        GetPage(name: '/ventas/newVendedor', page:()=> VendedoresPage()),
        GetPage(name: '/calidad/orders/list', page:()=> CalidadOtListPage()),
        GetPage(name: '/compras/orders/new_order/oc', page:()=> OcPage()),
        GetPage(name: '/compras/orders/new_order', page:()=> ProductPage()),
        GetPage(name: '/tym/orders/list', page:()=> TiemposOtListPage()),
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



