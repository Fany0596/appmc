import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/roles/roles_controller.dart';
import 'package:maquinados_correa/src/models/Rol.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RolesPage extends StatelessWidget {

  RolesController con = Get.put(RolesController());

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona el rol'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
        child:ListView(
        children: con.user.roles != null ? con.user.roles!.map((Rol rol) {
          return _cardRol(rol);
        }).toList() : [],
        ),

      ),

    );
  }

  Widget _cardRol(Rol rol){
    return GestureDetector(
      onTap: () => con.goToPageRol(rol),
      child: Column(
        children: [
          Container(// imagen
            margin: EdgeInsets.only(bottom: 1, top: 30),
            height: 100,
            child: CachedNetworkImage(
              imageUrl: rol.image!,
              fit: BoxFit.contain,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: (context, url) => CircularProgressIndicator(), // Widget de carga
              errorWidget: (context, url, error) => Icon(Icons.error), // Widget de error
            ),
          ),
          // Container(// imagen
          //   margin: EdgeInsets.only(bottom: 1, top: 30),
          //   height: 100,
          //   child: FadeInImage(
          //     image: NetworkImage(rol.image!),
          //     fit:BoxFit.contain,
          //     fadeInDuration: Duration(milliseconds: 50),
          //     placeholder: AssetImage('assets/img/no-image.png'),
          //   ),
          // ),
          Text(
            rol.name ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black
            ),
          )
        ],
      ),
    );
  }
  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25,left: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [Image.asset(
            'assets/img/LOGO1.png',
            width: 100, //ancho de imagen
            height: 100, //alto de imagen
          ),
            Text(
              '     MAQUINADOS CORREA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ]
      ),
    );
  }
}
