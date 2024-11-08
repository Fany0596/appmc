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
      drawer: Drawer(
        child: Container(
          color: Colors.white60,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 57), // Margen superior
                CircleAvatar(
                  backgroundImage: con.user.image != null
                      ? NetworkImage(con.user.image!)
                      : AssetImage('assets/img/LOGO1.png') as ImageProvider,
                  radius: 70,
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 10),
                Text(
                  '${con.user.name ?? ''}  ${con.user.lastname}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => con.goToPerfilPage(),
                  child: Container(
                    margin: EdgeInsets.only(top: 40, left: 1),
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    color: Colors.white,
                    child: Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, left: 160),
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () => con.signOut(),
                      icon: Icon(
                        Icons.power_settings_new,
                        color: Colors.black,
                        size: 30,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 100,
        title: _encabezado(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double gridCrossAxisCount = 1; // Valor por defecto: 1 rol por fila

          // Ajustar el número de columnas según el ancho disponible
          if (constraints.maxWidth > 600) {
            gridCrossAxisCount = 2;
          }
          if (constraints.maxWidth > 900) {
            gridCrossAxisCount = 3;
          }

          return Container(
            margin: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.04),
            child: con.user.roles != null
                ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCrossAxisCount.toInt(),
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.5,
              ),
              itemCount: con.user.roles!.length,
              itemBuilder: (context, index) {
                return _cardRol(con.user.roles![index]);
              },
            )
                : Center(child: Text('No hay roles disponibles')),
          );
        },
      ),
    );
  }

  Widget _cardRol(Rol rol) {
    return GestureDetector(
      onTap: () => con.goToPageRol(rol),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 1, top: 30),
            height: 100,
            child: CachedNetworkImage(
              imageUrl: rol.image!,
              fit: BoxFit.contain,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Text(
            rol.name ?? '',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/img/LOGO1.png',
            width: 100,
            height: 100,
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
