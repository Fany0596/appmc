import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/Client.dart';
import 'package:maquinados_correa/src/models/Materiales.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/models/vendedor.dart';
import 'package:maquinados_correa/src/pages/ventas/cotizacion/Cotizacion/create_cot_controller.dart';

class CombinedCotizacionProductoPage extends StatelessWidget {
  final CombinedController con = Get.put(CombinedController());
  final NumberFormat currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: _buildDrawer(),
        appBar: _buildAppBar(),
        body: TabBarView(
            children: [
              _datosTab(),
              _productosTab(),
              _extrasTab(),
            ],

        )
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
            Tab(text: 'Extras'),
          ],
        ),
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
              _buildDrawerItem('Registro de nuevo vendedor', () => con.goToNewVendedorPage()),
              _buildDrawerItem('Registro de nuevo cliente', () => con.goToNewClientePage()),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
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
  Widget _productosTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _textProduct(),
          _productoTableForm(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: con.addProductForm,
                icon: Icon(Icons.add),
                label: Text('Agregar'),
              ),

            ],
          ),
          _listaPendientes(),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => con.agregarProducto(Get.context!),
            child: Text('GUARDAR PRODUCTOS'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green
            ),
          ),
        ],
      ),
    );
  }

  Widget _extrasTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 20),
                child: _extraForm(),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                child: _comentForm(),
              ),
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 150),
              child: _buttonSaveAll(Get.context!)
          ),
        ],
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
                Text(
                  '    NUEVA COTIZACION',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ]
          ),
        ],
      ),
    );
  }
  Widget _boxForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _textNewCot(),
          _cotizacionForm(),
        ],
      ),
    );
  }
  Widget _textNewCot() {
    return Container(
      margin: EdgeInsets.only(bottom: 1, left: 10, right: 10),
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

  Widget _cotizacionForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _textFielNumber()), // Expande cada widget para ajustarse al espacio disponible
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child: _textFielFecha(Get.context!)),
            SizedBox(width: 10),
            Expanded(child: _textFieldReq()),
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child: _clientesList(con.clientes)), // Expande cada widget para ajustarse al espacio disponible
          ],
        ),
        Row(
          children: [
            Expanded(child: _textFielEnt()), // Expande cada widget para ajustarse al espacio disponible
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child:  Obx(() => _textFieldCondiciones())),
            SizedBox(width: 10),
            Expanded(child: _textFieldDescuento()),
            SizedBox(width: 10),
            Expanded(child: _vendedoresList(con.vendedores)),
          ],
        ),
        _textContact(),
        Row(
          children: [
            Expanded(child:  _textFielName()), // Expande cada widget para ajustarse al espacio disponible
            SizedBox(width: 10), // Espacio entre los campos
            Expanded(child: _textFielCorreo()),
            SizedBox(width: 10),
            Expanded(child: _textFieldPhone()),
          ],
        ),
      ],
    );
  }

  /*Widget _cotizacionForm() {
    return Column(
      children: [
        _textFielNumber(),
        _textFielFecha(Get.context!),
        _textFieldReq(),
        _clientesList(con.clientes),
         _textFielEnt(),
        _textFieldCondiciones(),
        _textFieldDescuento(),
        _vendedoresList(con.vendedores),
        _textContact(),
        _textFielName(),
        _textFielCorreo(),
        _textFieldPhone()
      ],
    );
  }*/

  Widget _textFielNumber() {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.numberController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Número de cotizacion', //texto fondo
          prefixIcon: Icon(Icons.numbers), //icono
        ),
      ),
    );
  }

  Widget _textFielFecha(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      child: GestureDetector(
        onTap: () {
          _selectDat(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.fechaController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Fecha',
              hintStyle: TextStyle(fontSize: 14),
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
      con.fechaController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Widget _textFielEnt() {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.entController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Tiempo de entrega', //texto fondo
          prefixIcon: Icon(Icons.timer), //icono
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
              color: Colors.black
          ),
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
            child: Text('50 % Anticipo y 50% despues de la entrega.'),
            value: '50 % Anticipo y 50% despues de la entrega.',
          ),
        ],
        value: con.selectedCondition.value.isEmpty ? null : con.selectedCondition.value,
        onChanged: (value) {
          con.selectedCondition.value =
          value!; // Actualizar el valor seleccionado
          con.condicionesController.text = value;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _textFieldReq() {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.reqController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Requerimiento',
            prefixIcon: Container(child: Icon(Icons.quiz_outlined))),
      ),
    );
  }

  Widget _textFieldDescuento() {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.descuentoController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Descuento',
            prefixIcon: Container(child: Icon(Icons.percent_outlined))),
      ),
    );
  }

  // lista vendedores
  Widget _vendedoresList(List<Vendedores> vendedores) {
    return Obx(() =>Container(
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
          'Vendedor',
          style: TextStyle(fontSize: 18,
          color: Colors.black),
        ),
        items: _dropDownItems(vendedores),
        value: con.idVendedores.value == '' ? null : con.idVendedores.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idVendedores.value = option.toString();
        },
        decoration: InputDecoration(
        border: InputBorder.none,
    ),
    ),
    ));
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Vendedores> vendedores) {
    List<DropdownMenuItem<String>> list = [];
    vendedores.forEach((vendedores) {
      list.add(DropdownMenuItem(
        child: Text(vendedores.name ?? ''),
        value: vendedores.id,
      ));
    });
    return list;
  }

  Widget _clientesList(List<Clientes> clientes) {
    return Obx(() => Container(
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
          'Cliente',
          style: TextStyle(fontSize: 18,
              color: Colors.black),
        ),
        items: _dropDownItemsc(clientes),
        value: con.idClientes.value == '' ? null : con.idClientes.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idClientes.value = option.toString();
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    ));
  }

  List<DropdownMenuItem<String>> _dropDownItemsc(List<Clientes> clientes) {
    List<DropdownMenuItem<String>> list = [];
    clientes.forEach((vendedores) {
      list.add(DropdownMenuItem(
        child: Text(vendedores.name ?? ''),
        value: vendedores.id,
      ));
    });
    return list;
  }

  Widget _textContact() {
    return Container(
      margin: EdgeInsets.only(top: 50, left: 10, right: 10),
      child: Text(
        'PERSONA DE CONTACTO',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }

  Widget _textFielName() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: TextField(
          controller: con.nombreController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Nombre', //texto fondo
            prefixIcon: Icon(Icons.perm_identity), //icono
          )),
    );
  }

  Widget _textFielCorreo() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: TextField(
          controller: con.correoController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Correo', //texto fondo
            prefixIcon: Icon(Icons.email_outlined), //icono
          )),
    );
  }

  Widget _textFieldPhone() {
    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 5, left: 10, right: 10),
      child: TextField(
        controller: con.telefonoController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Telefono', prefixIcon: Icon(Icons.phone)),
      ),
    );
  }


  /*Widget _productoForm() {
    return Column(
      children: [
        _textProduct(),
        _textFieldDescription(),
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

  Widget _productoTableForm() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          // Encabezados de la tabla
          Row(
            children: [
              Expanded(flex: 1,child: _tableHeader('ITEM')),
              Expanded(flex: 10, child: _tableHeader('Descripción')),
              Expanded(flex: 2,child: _tableHeader('Cantidad')),
              Expanded(flex: 2,child: _tableHeader('Precio Unitario')),
              Expanded(flex: 3,child: _tableHeader('Total')),
              SizedBox(width: 40), // Espacio para el botón de eliminar
            ],
          ),
          // Filas de productos
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: con.productForms.length,
            itemBuilder: (context, index) {
              return _productRow(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _productRow(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Cambiar TableCell por un Container u otro widget compatible con Row
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center, // Centrar el texto
              child: Text('${index + 1}'), // Mostrar el número de ITEM
            ),
          ),
          Expanded(
            flex: 10,
            child: _textFieldDescription(index),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _textFielCantidad(index),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _textFielPrecio(index),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: _textFielTotal(index),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => con.removeProductForm(index),
          ),
        ],
      ),
    );
  }

  Widget _textFieldDescription(int index) {
    return TextField(
      controller: con.productForms[index].descrController,
      decoration: InputDecoration(
        hintText: 'Descripción',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _textFielCantidad(int index) {
    return TextField(
      controller: con.productForms[index].cantidadController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Cantidad',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _textFielPrecio(int index) {
    return TextField(
      controller: con.productForms[index].precioController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Precio',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _textFielTotal(int index) {
    return TextField(
      controller: con.productForms[index].totalController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Total',
        border: OutlineInputBorder(),
      ),
      readOnly: true,
    );
  }
  Widget _buttonSaveAll(BuildContext context) {
    return ElevatedButton(
      onPressed: () => con.guardarCotizacionYProductos(context),
      child: Text('CREAR COTIZACIÓN'),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green
      ),
    );
  }
  Widget _listaPendientes() {
    return GetBuilder<CombinedController>(
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
                  Producto producto = entry.value;
                  return TableRow(
                    children: [
                      _tableCell('${idx +1}'),
                      _tableCell(producto.descr ?? ''),
                      _tableCell(producto.cantidad?.toString() ?? ''),
                      _tableCell(currencyFormatter.format(producto.precio ?? 0)),
                      _tableCell(currencyFormatter.format(producto.total ?? 0)),
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

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(thickness: 2,
       color: Colors.black,),
    );
  }
  Widget _comentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea los widgets a la izquierda
      children: [
        _textComent(),
        _coment1Switch(),
        _coment2Switch(),
        _coment3Switch()
      ],
    );
  }
  Widget _textComent() {
    return Container(
      margin: EdgeInsets.only(bottom: 1, left: 10, right: 10),
      child: Text(
        'COMENTARIOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        //),
      ),
    );
  }
  Widget _coment1Switch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'La vigencia de esta cotización será de 15 dias a partir de esta fecha.',
            style: TextStyle(fontSize: 16),
          ),
          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneComent1.value,
            onChanged: (value) {
              con.tieneComent1.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _coment2Switch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Los precios son en moneda nacional.',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneComent2.value,
            onChanged: (value) {
              con.tieneComent2.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _coment3Switch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'La entrega es hasta el almacén del cliente sin costo adicional, así como las visitas técnicas que se requieran.',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneComent3.value,
            onChanged: (value) {
              con.tieneComent3.value = value;
            },
          )),
        ],
      ),
    );
  }

  Widget _extraForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea los widgets a la izquierda
      children: [
        _textExt(),
        _garantiaSwitch(),
        _bancwitch(),
        _agreg1witch(),
        _agreg2witch(),
        _agreg3witch(),
        _agreg4witch(),
      ],
    );
  }
  Widget _textExt() {
    return Container(
      margin: EdgeInsets.only(bottom: 1, left: 10, right: 10),
      child: Text(
        'SELECCIONE VALORES EXTRA',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        //),
      ),
    );
  }
  Widget _garantiaSwitch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Garantías',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneGarantia.value,
            onChanged: (value) {
              con.tieneGarantia.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _bancwitch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Datos bancarios',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneBanc.value,
            onChanged: (value) {
              con.tieneBanc.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _agreg1witch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Reportde dimensional',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneAgreg1.value,
            onChanged: (value) {
              con.tieneAgreg1.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _agreg2witch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Reportde de rugosidad',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneAgreg2.value,
            onChanged: (value) {
              con.tieneAgreg2.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _agreg3witch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Certificado de tratamiento',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneAgreg3.value,
            onChanged: (value) {
              con.tieneAgreg3.value = value;
            },
          )),
        ],
      ),
    );
  }
  Widget _agreg4witch() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            'Certificado de material',
            style: TextStyle(fontSize: 16),
          ),

          Obx(() => Switch(
            activeColor: Colors.green,
            inactiveThumbColor: Colors.black,
            value: con.tieneAgreg4.value,
            onChanged: (value) {
              con.tieneAgreg4.value = value;
            },
          )),
        ],
      ),
    );
  }
}