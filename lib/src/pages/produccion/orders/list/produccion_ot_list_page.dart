import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/produccion/orders/list/produccion_ot_list_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/utils/relative_time_util.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';

class ProduccionOtListPage extends StatelessWidget {
  ProduccionOtListController con = Get.put(ProduccionOtListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: con.status.length,
          child: Scaffold(
            drawer: Drawer(
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
                              : AssetImage('assets/img/LOGO1.png')
                                  as ImageProvider,
                          radius: 70,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 0),
                        child: Text(
                          '${con.user.value.name ?? ''} ${con.user.value.lastname}',
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
                            'Registro de nuevo usuario',
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
                                color: Colors.black,
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
                                color: Colors.black,
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
            ),
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
                tabs: con.status
                    .map((status) => Tab(child: Text(status)))
                    .toList(),
              ),
            ),
            body: Column(
              children: [
                _searchBar(),
                Expanded(
                  child: TabBarView(
                    children: con.status.map((status) {
                      return FutureBuilder(
                        future: con.getCotizacion(status),
                        builder: (context,
                            AsyncSnapshot<List<Cotizacion>> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length > 0) {
                              return ListView.builder(
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (_, index) {
                                  return _cardCotizacion(snapshot.data![index]);
                                },
                              );
                            } else {
                              return Center(
                                  child: NoDataWidget(
                                      text: 'No hay cotizaciones'));
                            }
                          } else {
                            return Center(
                                child:
                                    NoDataWidget(text: 'No hay cotizaciones'));
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          con.filterCotizaciones(value);
        },
        decoration: InputDecoration(
          hintText: 'Buscar por número o cliente',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
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
            width: 55,
            height: 55,
          ),
        ],
      ),
    );
  }

  Widget _cardCotizacion(Cotizacion cotizacion) {
    return GestureDetector(
      onTap: () => con.goToDetalles(cotizacion),
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
                  'Cotización: #${cotizacion.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Cliente: ${cotizacion.clientes?.name ?? ''}'),
                  Text('Vendedor: ${cotizacion.vendedores?.name ?? ''}'),
                  Text(
                      'Contacto: ${cotizacion.nombre ?? ''} ${cotizacion.correo ?? ''}'),
                  Text('Teléfono: ${cotizacion.telefono ?? ''}'),
                  Text('Correo: ${cotizacion.correo ?? ''}'),
                  Text('Fecha: ${cotizacion.fecha ?? ''}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonReload() {
    return SafeArea(
      // deja espacio de la barra del telefono
      child: Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(right: 20),
        child: IconButton(
            onPressed: () => con.reloadPage(),
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            )),
      ),
    );
  }
}
