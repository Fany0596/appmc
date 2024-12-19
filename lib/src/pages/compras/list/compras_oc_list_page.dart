import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:maquinados_correa/src/models/oc.dart';
import 'package:maquinados_correa/src/pages/compras/list/compras_oc_list_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';

class ComprasOcListPage extends StatelessWidget {
  ComprasOcListController con = Get.put(ComprasOcListController());
  final RxBool isHoveredPerfil =
      false.obs; // Estado para el hover del botón "Perfil"
  final RxBool isHoveredProv = false.obs;
  final RxBool isHoveredRoles = false.obs;
  final RxBool isHoveredSalir = false.obs;

  @override
  Widget build(BuildContext context) {
    // Determinar el ancho del drawer basado en el ancho de la pantalla
    double drawerWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.45
        : MediaQuery.of(context).size.width * 0.14;


    return Obx(() => ZoomDrawer(
      controller: con.zoomDrawerController,
      menuScreen: _buildMenuScreen(context),
      mainScreen: _buildMainScreen(context),
      mainScreenScale: 0.0,
      slideWidth: drawerWidth,
      menuScreenWidth: drawerWidth,
      borderRadius: 0,
      showShadow: false,
      angle: 0.0,
      menuBackgroundColor: Colors.grey,
      mainScreenTapClose: true,
    ));
  }

  Widget _buildMenuScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.25;
    final screenHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.25;
    final containerHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.48
        : MediaQuery.of(context).size.width * 0.145;
    final textHeight = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.48
        : MediaQuery.of(context).size.width * 0.11;
    return Scaffold(
        backgroundColor: Colors.grey,
        body: Container(
            width: double.infinity,
            height:
            MediaQuery.of(context).size.height, // Altura total de la pantalla
            child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                              children: [
                                Container(
                                  height: containerHeight,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/img/fondo2.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topCenter,
                                        margin: EdgeInsets.only(top: screenHeight * 0.02),
                                        child: CircleAvatar(
                                          backgroundImage: con.user.value.image != null
                                              ? NetworkImage(con.user.value.image!)
                                              : AssetImage('assets/img/LOGO1.png')
                                          as ImageProvider,
                                          radius: screenWidth * 0.2,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, bottom: 0),
                                        child: Text(
                                          '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 1, bottom: 0),
                                        child: Text(
                                          '${con.user.value.email ?? ''}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Opciones del menú
                                MouseRegion(
                                  onEnter: (_) => isHoveredPerfil.value = true,
                                  onExit: (_) => isHoveredPerfil.value = false,
                                  child: GestureDetector(
                                    onTap: () => con.goToPerfilPage(),
                                    child: Obx(() => Container(
                                      margin:
                                      EdgeInsets.only(top: screenHeight * 0.05, left: 1),
                                      padding: EdgeInsets.all(screenWidth * 0.009),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isHoveredPerfil.value
                                            ? Colors.blueGrey
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 15),
                                              Icon(
                                                Icons.person,
                                                size: textHeight * 0.15,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 20),
                                              Text(
                                                'Perfil',
                                                style: TextStyle(
                                                  fontSize: textHeight * 0.09,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                                  ),
                                ),
                                MouseRegion(
                                  onEnter: (_) => isHoveredProv.value = true,
                                  onExit: (_) => isHoveredProv.value = false,
                                  child: GestureDetector(
                                    onTap: () => con.goToNewProveedorPage(),
                                    child: Obx(() => Container(
                                      margin:
                                      EdgeInsets.only(top: screenHeight * 0.05, left: 1),
                                      padding: EdgeInsets.all(screenWidth * 0.009),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isHoveredProv.value
                                            ? Colors.blueGrey
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 15),
                                              Icon(
                                                Icons.add_shopping_cart_outlined,
                                                size: textHeight * 0.15,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 20),
                                              Text(
                                                'Nuevo proveedor',
                                                style: TextStyle(
                                                  fontSize: textHeight * 0.09,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                                  ),
                                ),
                              ]
                          )
                      )
                  ),
                  // Botones en la parte inferior
                  Container(
                    decoration: BoxDecoration(
                        border: BorderDirectional(
                            top: BorderSide(
                              width: 2,
                              color: Color.fromARGB(070, 080, 080, 600),
                            ))),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    // Espaciado alrededor de los botones
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MouseRegion(
                          onEnter: (_) => isHoveredRoles.value = true,
                          onExit: (_) => isHoveredRoles.value = false,
                          child:GestureDetector(
                            onTap: () => con.goToRoles(),
                            child: Obx(() => Container(
                              padding: EdgeInsets.all(screenWidth * 0.009),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isHoveredRoles.value
                                    ? Colors.blueGrey
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(
                                        Icons.supervised_user_circle,
                                        //size: textHeight * 0.15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        'Roles',
                                        style: TextStyle(
                                          fontSize: textHeight * 0.09,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ),

                          ),
                        ),
                        MouseRegion(
                          onEnter: (_) => isHoveredSalir.value = true,
                          onExit: (_) => isHoveredSalir.value = false,
                          child:GestureDetector(
                            onTap: () => con.signOut(),
                            child: Obx(() => Container(
                              padding: EdgeInsets.all(screenWidth * 0.009),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isHoveredSalir.value
                                    ? Colors.blueGrey
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(
                                        Icons.output,
                                        //size: textHeight * 0.15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        'Salir',
                                        style: TextStyle(
                                          fontSize: textHeight * 0.09,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ),

                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return DefaultTabController(
      length: con.status.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110), //ancho del appbar
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => con.zoomDrawerController.toggle?.call(),
            ),
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
        ),
      ),
    );
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
          hintText: 'Buscar por OC o proveedor',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

}
