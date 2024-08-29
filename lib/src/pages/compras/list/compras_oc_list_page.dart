import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/pages/compras/list/compras_oc_list_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';

class ComprasOcListPage extends StatelessWidget {
  ComprasOcListController con = Get.put(ComprasOcListController());

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
                            '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => con.goToPerfilPage(), // funcion de boton
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
                          onTap: () => con.goToNewProveedorPage(),
                          // funcion de boton
                          child: Container(
                            margin: EdgeInsets.only(top: 10, left: 1),
                            padding: EdgeInsets.all(20),
                            width: double.infinity,
                            color: Colors.white,
                            child: Text(
                              'Registro de nuevo proveedor',
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
                                  )),
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
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(110), //ancho del appbar
                child: AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_encabezado(context)],
                  ),
                  flexibleSpace: Container(
                    margin: EdgeInsets.only(top: 30, bottom: 10),
                    alignment: Alignment.center,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [],
                    ),
                  ),
                  bottom: TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.grey,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: List<Widget>.generate(con.status.length, (index) {
                        return Tab(
                          child: Text(con.status[index]),
                        );
                      })),
                ),
              ),
              body: Column(
                children: [
                  _searchBar(context),
                  Expanded(
                      child: TabBarView(
                    children: con.status.asMap().entries.map((entry) {
                      int index = entry.key;
                      String status = entry.value;
                      return Obx(() {
                        if (con.searchText.isEmpty) {
                          return FutureBuilder(
                              future: con.getOc(status),
                              builder:
                                  (context, AsyncSnapshot<List<Oc>> snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.length > 0) {
                                    return ListView.builder(
                                        itemCount: snapshot.data?.length ?? 0,
                                        itemBuilder: (_, index) {
                                          return _cardOc(snapshot.data![index]);
                                        });
                                  } else {
                                    return Center(
                                        child: NoDataWidget(
                                            text: 'No hay ordenes'));
                                  }
                                } else {
                                  return Center(
                                      child:
                                          NoDataWidget(text: 'No hay ordenes'));
                                }
                              });
                        } else {
                          con.filterOc(status, index);
                          return ListView.builder(
                              itemCount: con.filteredOc.length,
                              itemBuilder: (_, i) {
                                return _cardOc(con.filteredOc[i]);
                              });
                        }
                      });
                    }).toList(),
                  )),
                ],
              )),
        ));
  }

  Widget _cardOc(Oc oc) {
    return GestureDetector(
      onTap: () => con.goToDetalles(oc),
      child: Container(
        height: 200,
        margin: EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )),
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0.5),
                          child: Text(
                            '${oc.number}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _showConfirmDeleteDialog(oc);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Provedor: ${oc.provedor?.name ?? ''}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Comprador: ${oc.comprador?.name ?? ''}'),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text('Contacto: ${oc.provedor!.nombre ?? ''} ')),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child:
                            Text('Telefono: ${oc.provedor!.telefono ?? ''}')),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text('Correo: ${oc.provedor!.correo ?? ''} ')),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text('Fecha: ${oc.soli ?? ''}')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDeleteDialog(Oc oc) {
    Get.defaultDialog(
      title: 'Confirmación',
      content: Text('¿Estás seguro de eliminar la oc ${oc.number}?'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back(); // Cierra el diálogo de confirmación
          },
          child: Text('No'),
        ),
        ElevatedButton(
          onPressed: () {
            con.deleteOc(oc); // Llama al método para eliminar el producto
            Get.back(); // Cierra el diálogo de confirmación
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text('Sí'),
        ),
      ],
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Image.asset(
          'assets/img/LOGO1.png',
          width: 55, //ancho de imagen
          height: 55, //alto de imagen
        ),
        Text(
          '  MAQUINADOS CORREA',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ]),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          con.searchText.value = value;
          con.filterOc(con.status[DefaultTabController.of(context)!.index],
              DefaultTabController.of(context)!.index);
        },
        decoration: InputDecoration(
          hintText: 'Buscar por OC o cliente',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

}
