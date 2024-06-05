///////////////////////
//          body:con.cotizacion.producto!.isNotEmpty
//     ? ListView(
//     children: con.cotizacion.producto!.map((Producto producto) {
//   return _cardProducto(context, producto);
//   }).toList(),
//   )
//     : Center(
// child: NoDataWidget(text: 'No hay ningun producto agregado aun')
// ),
//////
//TabBarView(
// children: con.estatus.map((String estatus){
//     return FutureBuilder(
//     future: con.getProducto(estatus),
//     builder: (context, AsyncSnapshot<List<Producto>> snapshot){
//           if (snapshot.hasData){
//              if (snapshot.data!.length > 0) {
//               return ListView.builder(
//                    itemCount: snapshot.data?.length ?? 0,
//                    itemBuilder: (_, index){
//                     return _cardProducto(snapshot.data![index]);
//                   }
//                );
//              }
//              else {
//                return Center(child: NoDataWidget(text:'No hay Producto'));
//              }
//            }
//            else{
//              return Center(child: NoDataWidget(text: 'No hay Producto'));
//           }
//          }
//      );
//   }
//   ).toList(),
// )
///////
// body: con.cotizacion.producto!.isNotEmpty
//     ? ListView(
//   children: _getFilteredProducts(context)
//       .map((Producto producto) => _cardProducto(producto))
//       .toList(),
// )
//     : Center(
//   child: NoDataWidget(text: 'No hay ningun producto agregado aun'),
// ),
// import 'package:flutter_test/flutter_test.dart';
// import 'package:maquinados_correa/src/models/producto.dart';
//
// import 'dart:convert';
//
// void main() {
//   String jsonString = '{"id": "1", "articulo": "Producto de prueba", "precio": 10.0, ...}';
//   Map<String, dynamic> jsonProducto = json.decode(jsonString);
//
//   // Mapea los datos de prueba a un objeto Producto
//   Producto producto = productoFromJson(jsonProducto);
//
//   // Verifica que los campos estén mapeados correctamente
