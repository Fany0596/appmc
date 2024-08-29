import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/tym/list/tym_ot_list_controller.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';

class TymOtListPage extends StatelessWidget {
  TymOtListController con = Get.put(TymOtListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
      length: con.estatus.length,
      child: Scaffold(
        drawer: _buildDrawer(),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _encabezado(context),
              _buttonReload(),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.grey,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            onTap: (index) {
              con.selectedStatus.value = con.estatus[index];
            },
            tabs: con.estatus.map((estatus) => Tab(child: Text(estatus))).toList(),
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                children: con.estatus.map((estatus) {
                  return Obx(() {
                    if (con.filteredProducts.isEmpty) {
                      return Center(child: NoDataWidget(text: 'No hay productos'));
                    } else {
                      return ListView.builder(
                        itemCount: con.filteredProducts.length,
                        itemBuilder: (_, index) {
                          return _cardProduct(con.filteredProducts[index]);
                        },
                      );
                    }
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) => con.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o OT',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1, left: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/img/LOGO1.png',
            width: 55, // ancho de imagen
            height: 55, // alto de imagen
          ),
          Text(
            '  MAQUINADOS CORREA',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardProduct(Producto producto) {
    return GestureDetector(
      onTap: () => con.goToOt(producto),
      child: Card(
        elevation: 3.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  '${producto.articulo}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            ListTile(
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('OT: ${producto.ot ?? ''}'),
                  Text('Cantidad: ${producto.cantidad.toString()}'),
                  Text('Status: ${producto.estatus ?? ''}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white60,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 57),
                child: CircleAvatar(
                  backgroundImage: con.user.value.image != null
                      ? NetworkImage(con.user.value.image!)
                      : AssetImage('assets/img/LOGO1.png') as ImageProvider,
                  radius: 70,
                  backgroundColor: Colors.transparent,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 0),
                child: Text(
                  '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
              GestureDetector(
                onTap: () => con.goToRegisterPage(),
                child: Container(
                  margin: EdgeInsets.only(top: 10, left: 1),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  color: Colors.white,
                  child: Text(
                    'Registro de nuevo operador',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 20),
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => con.goToRoles(),
                      icon: Icon(
                        Icons.supervised_user_circle,
                        color: Colors.white,
                        size: 30,
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
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buttonReload() {
    return SafeArea( // deja espacio de la barra del telefono
      child: Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(right: 20),
        child: IconButton(
            onPressed: () => con.reloadPage(),
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            )
        ),
      ),
    );
  }
}
