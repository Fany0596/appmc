import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/comprador.dart';
import 'package:maquinados_correa/src/models/cotizacion.dart';
import 'package:maquinados_correa/src/models/product.dart';
import 'package:maquinados_correa/src/models/provedor.dart';
import 'package:maquinados_correa/src/pages/compras/orders/create_oc/create_oc_controller.dart';

class CombinedOcProductPage extends StatelessWidget {
  final CombinedOcController con = Get.put(CombinedOcController());
  final NumberFormat currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          drawer: _buildDrawer(),
          appBar: _buildAppBar(),
          body: TabBarView(
            children: [
              _datosTab(),
              _productosTab(context),
            ],

          )
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white60,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDrawerHeader(),
              _buildDrawerItem('Perfil', () => con.goToPerfilPage()),
              _buildDrawerItem('Registro de nuevo proveedor', () => con.goToNewProveedorPage()),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 57),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: con.user.value.image != null
                ? NetworkImage(con.user.value.image!)
                : AssetImage('assets/img/LOGO1.png') as ImageProvider,
            radius: 70,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 10),
          Text(
            '${con.user.value.name ?? ''}  ${con.user.value.lastname}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 1),
        padding: EdgeInsets.all(20),
        width: double.infinity,
        color: Colors.white,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Row(
      children: [
        _buildIconButton(Icons.supervised_user_circle, () => con.goToRoles()),
        Spacer(),
        _buildIconButton(Icons.power_settings_new, () => con.signOut()),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: AppBar(
        title: _encabezado(Get.context!),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Datos'),
            Tab(text: 'Productos'),
          ],
        ),
      ),
    );
  }
  Widget _encabezado(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [
            Image.asset(
              'assets/img/LOGO1.png',
              width: 55, //ancho de imagen
              height: 55, //alto de imagen
            ),
            Text(
              '    NUEVA OC',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 10),
          ]),
    );
  }

  Widget _datosTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _boxForm(Get.context!),
        ],
      ),
    );
  }

  Widget _productosTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _textProduct(),
          _productoForm(),
          SizedBox(height: 20),
          _listaPendientes(),
          SizedBox(height: 50),
          _buttonSaveAll(context),
                  ],
      ),
    );
  }
  Widget _boxForm(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _textNewCot(),
          _cotizacionForm(context),
        ],
      ),
    );
  }
  Widget _textNewCot() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 1, left: 10, right: 10),
      child: Text(
        'INGRESE LOS SIGUIENTES DATOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        //),
      ),
    );
  }
  Widget _cotizacionForm(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _textFielNumber()), // Expande cada widget para ajustarse al espacio disponible
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child: _cotizacionList(con.cotizacion)),
            SizedBox(width: 10),
            Expanded(child: _provedorList(con.provedor)),
          ],
        ),
        Row(
          children: [ // Espacio entre los campos
            Expanded(child: _compradorList(con.comprador)),
            SizedBox(width: 10),
            Expanded(child: _textFielSoli(context)),
            SizedBox(width: 10),
            Expanded(child: _textFielEnt(context)),
          ],
        ),
        Row(
          children: [
            Expanded(child:  Obx(() => _textFieldCondiciones())),
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child: Obx(() => _textFieldMoneda())),
            SizedBox(width: 10),
            Expanded(child: Obx(() => _textFieldTipo())), // Expande cada widget para ajustarse al espacio disponible
          ],
        ),
        Container(
            margin: EdgeInsets.only(top: 20),
            child: _textFieldComent()),

      ],
    );
  }

  /*Widget _cotizacionForm(BuildContext context) {
    return Column(
      children: [
        _textFielNumber(),
        _cotizacionList(con.cotizacion),
        _provedorList(con.provedor),
        _compradorList(con.comprador),
        _textFielSoli(context),
        _textFielEnt(context),
        _textFieldCondiciones(),
        _textFieldMoneda(),
        _textFieldComent(),
      ],
    );
  }*/
  Widget _cotizacionList (List<Cotizacion> cotizacion){
    return Obx(() => Container(
      padding: EdgeInsets.only(left: 15, right: 10),
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
        icon: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.black
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Selecciona una cotización',
          style: TextStyle(
              fontSize: 18,
            color: Colors.black
          ),
        ),
        items: _dropDownItemsc(cotizacion),
        value: con.idCotizaciones.value == '' ? null : con.idCotizaciones.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idCotizaciones.value = option.toString();
        },
        decoration: InputDecoration(
          border: InputBorder.none,)
      ),
    ));
  }
  List<DropdownMenuItem<String>> _dropDownItemsc (List<Cotizacion> cotizacion){

    List<DropdownMenuItem<String>> list =[];
    cotizacion.forEach((cotizacion) {
      list.add(DropdownMenuItem(
        child: Text(cotizacion.number ?? ''),
        value: cotizacion.id,
      ));
    });
    return list;
  }
  Widget _textFielNumber() {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.numberController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Número de OC', //texto fondo
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.numbers), //icono
        ),
      ),
    );
  }
  Widget _provedorList (List<Provedor> provedor){
    return Obx(() => Container(
      padding: EdgeInsets.only(left: 15, right: 10),
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
        icon: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.black
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Selecciona un provedor',
          style: TextStyle(
              fontSize: 18,
            color: Colors.black
          ),
        ),
        items: _dropDownItems(provedor),
        value: con.idProvedor.value == '' ? null : con.idProvedor.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idProvedor.value = option.toString();
        },
    decoration: InputDecoration(
    border: InputBorder.none,
    )
      ),
    ));
  }
  List<DropdownMenuItem<String>> _dropDownItems (List<Provedor> provedor){

    List<DropdownMenuItem<String>> list =[];
    provedor.forEach((provedor) {
      list.add(DropdownMenuItem(
        child: Text(provedor.name ?? ''),
        value: provedor.id,
      ));
    });
    return list;
  }
  Widget _compradorList (List<Comprador> comprador){
    return Obx(() =>Container(
      padding: EdgeInsets.only( left: 15, right: 10),
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
        icon: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.black
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Selecciona un comprador',
          style: TextStyle(
              fontSize: 18,
             color: Colors.black
          ),
        ),
        items: _dropDownItemscc(comprador),
        value: con.idComprador.value == '' ? null : con.idComprador.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idComprador.value = option.toString();
        },
    decoration: InputDecoration(
    border: InputBorder.none,)
      ),
    ));
  }
  List<DropdownMenuItem<String>> _dropDownItemscc (List<Comprador> comprador){

    List<DropdownMenuItem<String>> list =[];
    comprador.forEach((comprador) {
      list.add(DropdownMenuItem(
        child: Text(comprador.name ?? ''),
        value: comprador.id,
      ));
    });
    return list;
  }

  Widget _textFielSoli(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: GestureDetector(
        onTap: () {
          _selectData(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.soliController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Fecha de solicitud',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(fontSize: 18),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      con.soliController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _textFielEnt(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: GestureDetector(
        onTap: () {
          _selectDat(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.entController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Fecha de entrega',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(fontSize: 18),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDat(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      con.entController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
  Widget _textFieldMoneda() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
          icon: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.black
          ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Moneda',
          style: TextStyle(fontSize: 18,
              color: Colors.black),
        ),
        items: [
          DropdownMenuItem(
            child: Text('MXN'),
            value: 'MXN',
          ),
          DropdownMenuItem(
            child: Text('USD'),
            value: 'USD',
          ),
        ],
          value: con.selectedMoneda.value.isEmpty ? null : con.selectedMoneda.value,
        onChanged: (value) {
          con.selectedMoneda.value = value!; // Actualizar el valor seleccionado
          con.monedaController.text = value;
        },
    decoration: InputDecoration(
    border: InputBorder.none,)
      ),
    );
  }
  Widget _textFieldTipo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
        icon: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.black
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Tipo de compra',
          style: TextStyle(fontSize: 18,
              color: Colors.black),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Acero'),
            value: 'Acero',
          ),
          DropdownMenuItem(
            child: Text('Insumo'),
            value: 'Insumo',
          ),
        ],
          value: con.selectedTipo.value.isEmpty ? null : con.selectedTipo.value,
        onChanged: (value) {
          con.selectedTipo.value = value!; // Actualizar el valor seleccionado
          con.tipoController.text = value;
        },
          decoration: InputDecoration(
            border: InputBorder.none,
          )
      ),
    );
  }
  Widget _textFieldComent() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.comentController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Comentarios',
            border: OutlineInputBorder(),
            prefixIcon: Container(
                child: Icon(Icons.description)
            )
        ),
      ),
    );
  }
  Widget _textFieldCondiciones() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
        icon: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.black
        ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Condiciones de pago',
          style: TextStyle(fontSize: 18,
              color: Colors.black),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Crédito'),
            value: 'Crédito',
          ),
          DropdownMenuItem(
            child: Text('Contado'),
            value: 'Contado',
          ),
          DropdownMenuItem(
            child: Text('50 % Anticipo y 50% despues de la entrega del material.'),
            value: '50 % Anticipo y 50% despues de la entrega del material.',
          ),
        ],
          value: con.selectedCondition.value.isEmpty ? null : con.selectedCondition.value,
        onChanged: (value) {
          con.selectedCondition.value = value!; // Actualizar el valor seleccionado
          con.condicionesController.text = value;
        },
    decoration: InputDecoration(
    border: InputBorder.none,
    )
      ),
    );
  }

  Widget _productoForm() {
    return Column(
      children: [
        Row(
          children: [
            Flexible(flex: 2, child: _textFieldDescription()), // Ocupa un tercio del espacio
            SizedBox(width: 10), // Espacio entre los campos
            Flexible(flex: 1, child: _materialesList(con.materiales)),
          ],
        ),
        Row(
          children: [
            Expanded(child:_textFieldUnid()),
            SizedBox(width: 10),
            Expanded(child:  _textFielCantidad()), // Expande cada widget para ajustarse al espacio disponible
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child:  _textFielPrecio()),
            SizedBox(width: 10),
            Expanded(child:_textFielTotal()),
          ],
        ),
        _buttonAddProduct(Get.context!),
      ],
    );
  }

  /*Widget _productoForm() {
    return Column(
      children: [
        _textProduct(),
         _textFieldDescription(),
        _materialesList(con.materiales),
        _textFieldUnid(),
        _textFielCantidad(),
        _textFielPrecio(),
        _textFielTotal(),
        _buttonAddProduct(Get.context!),
      ],
    );
  }*/

  Widget _textProduct() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 1, left: 10, right: 10),
      child: Text(
        'AGREGAR PRODUCTO',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }
  Widget _textFielTotal() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
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
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money_rounded), //icono
          )),
    );
  }
  Widget _textFielCantidad() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: TextField(
          controller: con.cantidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Cantidad', //texto fondo
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers), //icono
          )),
    );
  }
  Widget _textFieldUnid() {
    return Container(
        margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
        child: DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down_circle),
        decoration: InputDecoration(
          hintText: 'Unidad',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.horizontal_rule),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Pza.'),
            value: 'Pza.',
          ),
          DropdownMenuItem(
            child: Text('Kg.'),
            value: 'Kg.',
          ),
          DropdownMenuItem(
            child: Text('Mt.'),
            value: 'Mt.',
          ),
        ],
        onChanged: (value) {
          con.selectedUnid.value = value!; // Actualizar el valor seleccionado
          con.unidController.text = value;
        },
      ),
    );
  }
  Widget _textFielPrecio() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: TextField(
          controller: con.precioController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Precio Unitario', //texto fondo
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money), //icono
          )),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.descrController,
        keyboardType: TextInputType.text,

        decoration: InputDecoration(
            hintText: 'Descripción',
            border: OutlineInputBorder(),
            prefixIcon: Container(
                child: Icon(Icons.description)
            )
        ),
      ),
    );
  }
  Widget _materialesList(List<Materiales> materiales) {
    return Obx(() =>Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey)
      ),
      child: DropdownButtonFormField<String>(
        icon: Icon(
            Icons.arrow_drop_down_circle,
          ),
        elevation: 3,
        isExpanded: true,
        hint: Text(
          'Selecciona un material',
          style: TextStyle(fontSize: 16,
            color: Colors.black),
        ),
        items: _dropDownItemss(materiales),
        value: con.idMateriales.value == '' ? null : con.idMateriales.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idMateriales.value = option.toString();
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    ));
  }

  List<DropdownMenuItem<String>> _dropDownItemss(List<Materiales> materiales) {
    List<DropdownMenuItem<String>> list = [];
    materiales.forEach((materiales) {
      list.add(DropdownMenuItem(
        child: Text(materiales.name ?? ''),
        value: materiales.id,
      ));
    });
    return list;
  }

  Widget _listaPendientes() {
    return GetBuilder<CombinedOcController>(
      builder: (controller) => Column(
        children: [
          Text('Productos guardados: ${controller.productosPendientes.length}'),
          Container(
            margin: EdgeInsets.all(10),
            child: Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(1),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    _tableHeaderr('ITEM'),
                    _tableHeaderr('Descripción'),
                    _tableHeaderr('Cantidad'),
                    _tableHeaderr('Precio Unitario'),
                    _tableHeaderr('Total'),
                    _tableHeaderr('Acciones'),
                  ],
                ),
                ...controller.productosPendientes.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Product product = entry.value;
                  return TableRow(
                    children: [
                      _tableCell('${idx +1}'),
                      _tableCell(product.descr ?? ''),
                      _tableCell(product.cantidad?.toString() ?? ''),
                      _tableCell(currencyFormatter.format(product.precio ?? 0)),
                      _tableCell(currencyFormatter.format(product.total ?? 0)),
                      TableCell(
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.removeProducto(idx),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderr(String text) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(1),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buttonAddProduct(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: ElevatedButton(
        onPressed: () => con.agregarProducto(context),
        child: Text('AGREGAR PRODUCTO'),
      ),
    );
  }

  Widget _buttonSaveAll(BuildContext context) {
    return ElevatedButton(
      onPressed: () => con.guardarOcYProductos(context),
      child: Text('CREAR OC',
      style: TextStyle(fontSize: 20   ),),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green
      )
    );
  }

}