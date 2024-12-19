import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/pages/Generico/list/list_controller.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';

class ListPage extends StatelessWidget {
  ListController con = Get.put(ListController());
  final RxBool isHoveredPerfil = false.obs;
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
          preferredSize: Size.fromHeight(110),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => con.zoomDrawerController.toggle?.call(),
            ),
            title: _encabezado(context),
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.grey,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: List.generate(con.status.length, (index) {
                return Tab(child: Text(con.status[index]));
              }),
            ),
          ),
        ),
        body: Column(
          children: [
            _searchBar(),
            Expanded(
              child: TabBarView(
                children: con.status.map((String status) {
                  return FutureBuilder(
                    future: con.getCotizacion(status),
                    builder:
                        (context, AsyncSnapshot<List<Cotizacion>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) {
                              return _cardCotizacion(snapshot.data![index]);
                            },
                          );
                        } else {
                          return Center(
                              child:
                              NoDataWidget(text: 'No hay cotizaciones'));
                        }
                      } else {
                        return Center(
                            child: NoDataWidget(text: 'No hay cotizaciones'));
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
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
  Widget _cardCotizacion(Cotizacion cotizacion) {
    return GestureDetector(
      onTap: () => con.goToDetalles(cotizacion),
      child: Container(
        height: 150,
        margin: EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child:Stack(
            children: [
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                    borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                )
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    'Cotizacion: #${cotizacion.number}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                    ),
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
                        child: Text('Cliente: ${cotizacion.clientes?.name ?? ''}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Vendedor: ${cotizacion.vendedores?.name ?? ''}'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Fecha: ${ cotizacion.fecha ?? ''}')

                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1,left: 1),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [Image.asset(
            'assets/img/LOGO1.png',
            width: 55, //ancho de imagen
            height: 55, //alto de imagen
          ),
          ]
      ),
    );
  }


}


