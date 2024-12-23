import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/create_producto/create_producto_controller.dart';

class ProductoPage extends StatelessWidget {
  final ProductoPageController con = Get.put(ProductoPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => SingleChildScrollView(
            child: Stack(
              // posiciona elementos uno sobre otro
              children: [
                _backGroundCover(context),
                _boxForm(context),
                _buttonReload(),
                _encabezado(context),
                _textAdd(context)
              ],
            ),
          )),
    );
  }

  // fondo gris
  Widget _backGroundCover(BuildContext context) {
    //build context para porcentaje
    return Container(
        width: double.infinity, //ancho de imagen
        height: MediaQuery.of(context).size.height * 0.38, //alto de imagen
        color: Colors.grey);
  }

  // caja de datos
  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 1.30,
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.29, left: 30, right: 20),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textNewCot(),
          _cotizacionList(con.cotizacion),
          _materialesList(con.materiales),
          _textFielArticulo(),
          _textFieldDescription(),
          _textFielPrecio(),
          _textFielCantidad(),
          _textFielTotal(),
          _buttonAddProduct(context),
          _listaPendientes(),
          _buttonSaveAll(context)
        ],
      ),
    );
  }

  Widget _listaPendientes() {
    return GetBuilder<ProductoPageController>(
      builder: (controller) => Column(
        children: [
          Text(
              'Productos pendientes de guardar: ${controller.productosPendientes.length}'),
          Container(
            height: 200, // Ajusta este valor según tus necesidades
            child: ListView.builder(
              itemCount: controller.productosPendientes.length,
              itemBuilder: (context, index) {
                final producto = controller.productosPendientes[index];
                return ListTile(
                  title: Text(producto.articulo ?? 'Sin artículo'),
                  subtitle: Text(
                      'Cantidad: ${producto.cantidad ?? 0}, Precio: ${producto.precio ?? 0.0}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      controller.removeProducto(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonAddProduct(BuildContext context) {
    return ElevatedButton(
      onPressed: () => con.agregarProducto(context),
      child: Text('AGREGAR PRODUCTO'),
    );
  }

  Widget _buttonSaveAll(BuildContext context) {
    return ElevatedButton(
      onPressed: () => con.guardarTodosLosProductos(context),
      child: Text('GUARDAR TODOS LOS PRODUCTOS'),
    );
  }

  // Texto ingrese datos
  Widget _textNewCot() {
    return Text(
      'INGRESE LOS SIGUIENTES DATOS',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      //),
    );
  }

  // Texto numero
  Widget _textFielArticulo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
          controller: con.articuloController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Articulo', //texto fondo
            prefixIcon: Icon(Icons.add_circle), //icono
          )),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.descrController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Descripción',
            prefixIcon: Container(child: Icon(Icons.description))),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [
            Image.asset(
              'assets/img/LOGO1.png',
              width: 100, //ancho de imagen
              height: 100, //alto de imagen
            ),
            SizedBox(width: 10),
          ]),
    );
  }

  // imagen
  Widget _textAdd(BuildContext context) {
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 70, bottom: 15),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_motion, size: 105),
            Text(
              'NUEVO PRODUCTO',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 26),
            ),
          ],
        ),
      ),
    );
  }

  // lista vendedores

  Widget _materialesList(List<Materiales> materiales) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      //margin: EdgeInsets.only(top: 10),
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.grey,
          ),
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Selecciona un material',
          style: TextStyle(fontSize: 16),
        ),
        items: _dropDownItems(materiales),
        value: con.idMateriales.value == '' ? null : con.idMateriales.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idMateriales.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Materiales> materiales) {
    List<DropdownMenuItem<String>> list = [];
    materiales.forEach((materiales) {
      list.add(DropdownMenuItem(
        child: Text(materiales.name ?? ''),
        value: materiales.id,
      ));
    });
    return list;
  }

  Widget _cotizacionList(List<Cotizacion> cotizacion) {
    return Obx(() => Container(
          padding: EdgeInsets.only(top: 13, bottom: 0, left: 15, right: 10),
          //margin: EdgeInsets.only(top: 10),
          child: DropdownButton(
            underline: Container(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.grey,
              ),
            ),
            elevation: 3,
            isExpanded: true,
            hint: Text(
              'Selecciona un número de cotización',
              style: TextStyle(fontSize: 16),
            ),
            items: _dropDownItemsc(cotizacion),
            value: con.idCotizaciones.value == ''
                ? null
                : con.idCotizaciones.value,
            onChanged: (option) {
              print('Opcion seleccionada ${option}');
              con.idCotizaciones.value = option.toString();
            },
          ),
        ));
  }

  List<DropdownMenuItem<String>> _dropDownItemsc(List<Cotizacion> cotizacion) {
    List<DropdownMenuItem<String>> list = [];
    cotizacion.forEach((cotizacion) {
      list.add(DropdownMenuItem(
        child: Text(cotizacion.number ?? ''),
        value: cotizacion.id,
      ));
    });
    return list;
  }

  Widget _textFielPrecio() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.precioController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Precio Unitario', //texto fondo
            prefixIcon: Icon(Icons.attach_money), //icono
          )),
    );
  }

  Widget _textFielCantidad() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.cantidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Cantidad', //texto fondo
            prefixIcon: Icon(Icons.numbers), //icono
          )),
    );
  }

  Widget _textFielTotal() {
    return Container(
      margin: EdgeInsets.only(top: 1, bottom: 1, left: 10, right: 10),
      child: TextField(
          controller: con.totalController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'), // Acepta hasta dos decimales
            ),
          ],
          decoration: InputDecoration(
            hintText: 'Total', //texto fondo
            prefixIcon: Icon(Icons.attach_money_rounded), //icono
          )),
    );
  }

  Widget _buttonReload() {
    return SafeArea(
      // deja espacio de la barra del telefono
      child: Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(right: 20, top: 120),
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
