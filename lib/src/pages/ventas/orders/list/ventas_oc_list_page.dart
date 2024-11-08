import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/ventas/orders/list/ventas_oc_list_controller.dart';
import 'package:get/get.dart';
import 'package:maquinados_correa/src/widgets/no_data_widget.dart';

class VentasOcListPage extends StatelessWidget {
 VentasOcListController con = Get.put(VentasOcListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
        length: con.status.length,
        child:  Scaffold(
          drawer: Drawer(
            child: Container(
              color: Colors.white60,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top:57),
                    child: CircleAvatar(
                      backgroundImage:  con.user.value.image != null
                          ? NetworkImage(con.user.value.image!)
                          :AssetImage('assets/img/LOGO1.png') as ImageProvider,
                      radius: 70,
                      backgroundColor: Colors.transparent,
                    ),
                    ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 0),
                    child: Text('${con.user.value.name ?? ''}  ${con.user.value.lastname}',
                      style:TextStyle(
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
                      onTap: () => con.goToNewVendedorPage(), // funcion de boton
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 1),
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          'Registro de nuevo vendedor',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => con.goToNewClientePage(), // funcion de boton
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 1),
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          'Registro de nuevo cliente',
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
                        margin: EdgeInsets.only(top: 20, left: 20 ),
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => con.goToRoles(),
                            icon: Icon(
                              Icons.supervised_user_circle,
                              color: Colors.black,
                              size: 30,
                            )
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 160 ),
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => con.signOut(),
                            icon: Icon(
                              Icons.power_settings_new,
                              color: Colors.black,
                              size: 30,
                            )
                        ),
                      ),
                    ],
                  ),
                    ],
                  ),
              ),
          ),
          ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(120),//ancho del appbar
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _encabezado(context),
                  _buttonReload(),
                ],
              ),
              flexibleSpace: Container(
                margin: EdgeInsets.only(top: 30, bottom: 10),
                alignment: Alignment.center,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                  ],
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
                })
              ),
            ),
          ),
          body: Column(
            children: [
              _searchBar(),
              Expanded(
                child: TabBarView(
                  children: con.status.map((String status){
                    return FutureBuilder(
                        future: con.getCotizacion(status),
                        builder: (context, AsyncSnapshot<List<Cotizacion>> snapshot){
                          if (snapshot.hasData){
                            if (snapshot.data!.length > 0) {
                              return ListView.builder(
                                  itemCount: snapshot.data?.length ?? 0,
                                  itemBuilder: (_, index){
                                    return _cardCotizacion(snapshot.data![index]);
                                  }
                                  );
                            }
                            else {
                              return Center(child: NoDataWidget(text:'No hay cotizaciones'));
                            }
                          }
                          else{
                            return Center(child: NoDataWidget(text: 'No hay cotizaciones'));
                          }
                        }
                    );
                  }).toList(),
                ),
              ),
            ],
          )
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
  Widget _cardCotizacion(Cotizacion cotizacion) {
    return GestureDetector(
      onTap: () => con.goToDetalles(cotizacion),
      child: Container(
        height: 200,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0.5),
                          child: Text(
                            '${cotizacion.number}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _showConfirmDeleteDialog(cotizacion);
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
                        child: Text('Contacto: ${ cotizacion.nombre ?? ''}  ${cotizacion.correo ?? ''} ')

                    ),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text('Telefono: ${cotizacion.telefono ?? ''}')

                    ),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text('Correo: ${cotizacion.correo ?? ''} ')

                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text('Fecha: ${cotizacion.fecha ?? ''}')

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
 void _showConfirmDeleteDialog(Cotizacion cotizacion) {
   Get.defaultDialog(
     title: 'Confirmación',
     content: Text('¿Estás seguro de eliminar la cotizacion ${cotizacion.number}?'),
     actions: [
       ElevatedButton(
         onPressed: () {
           Get.back(); // Cierra el diálogo de confirmación
         },
         child: Text('No'),
       ),
       ElevatedButton(
         onPressed: () {
           con.deleteCotizacion(cotizacion); // Llama al método para eliminar el producto
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
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Image.asset(
                'assets/img/LOGO1.png',
                width: 55, //ancho de imagen
                height: 55, //alto de imagen
              ),
              ]
          ),
        ],
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


