import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maquinados_correa/src/models/operador.dart';
import 'package:maquinados_correa/src/models/producto.dart';
import 'package:maquinados_correa/src/pages/tym/list/tiempos/tiempos_controller.dart';

class TiemposPage extends StatelessWidget {
  Producto? producto;
  final TiemposController con = Get.put(TiemposController());

  TiemposPage({@required this.producto});

  @override
  Widget build(BuildContext context) {
    return Obx (() => Scaffold(
       body: SingleChildScrollView(
      child: Stack(
        children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.start, // posiciona elementos uno sobre otro
        children: [
          _backGroundCover(context),
        ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // posiciona elementos uno sobre otro
             children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _encabezado(),
                ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 1),
                 child: _buttonBack(),
               ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: _textArticulo(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _boxForm(context),
                ),
              ],
            ),
        ],
      ),
      ),
       ),
    );
  }

  Widget _backGroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.28,
      color: Colors.grey,
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        Image.asset(
          'assets/img/LOGO1.png',
          width: 55,
          height: 55,
        ),
        const SizedBox(width: 10),
        Text(
          'MAQUINADOS CORREA',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _textArticulo() {
    return
        Text(
          'TIEMPOS Y MOVIMIENTOS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),

    );
  }

  Widget _boxForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 0.085),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textNewCot(),
          _textFielProceso(),
          _operadorList(con.operador),
          _textFielEnt(context),
          _textFielStatus(),
          _textFieldComent(),
          //_getDatePickerEnabled(context),
          //_entrega(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              con.producto!.estatus == 'EN ESPERA'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'EN PROCESO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'SUSPENDIDO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'SIG. PROCESO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'RECHAZADO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
              con.producto!.estatus == 'RETRABAJO'
                  ? Container(
                  child: _buttonSave(context))
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textNewCot() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15, left: 20),
      child: Text(
        'INGRESE LOS SIGUIENTES DATOS',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _textFielProceso() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down_circle,
          color: Colors.grey,),
        decoration: InputDecoration(
          hintText: 'Proceso',
          prefixIcon: Icon(Icons.handyman_outlined),
        ),
        items: [
          DropdownMenuItem(
            child: Text('Torneado'),
            value: 'Torneado',
          ),
          DropdownMenuItem(
            child: Text('Fresado'),
            value: 'Fresado',
          ),
          DropdownMenuItem(
            child: Text('Barrenado'),
            value: 'Barrenado',
          ),
          DropdownMenuItem(
            child: Text('Machueleado'),
            value: 'Machueleado',
          ),
          DropdownMenuItem(
            child: Text('Soldadura'),
            value: 'Soldadura',
          ),
          DropdownMenuItem(
            child: Text('Cuñero'),
            value: 'Cuñero',
          ),
        ],
        onChanged: (value) {
          con.onProcesoSelected(value);
        },
      ),
    );
  }

  Widget _operadorList(List<Operador> operador) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
          'Selecciona un operador',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        items: _dropDownItems(operador),
        value: con.idOperador.value == '' ? null : con.idOperador.value,
        onChanged: (option) {
          print('Opcion seleccionada ${option}');
          con.idOperador.value = option.toString();
        },
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Operador> operador) {
    List<DropdownMenuItem<String>> list = [];
    operador.forEach((operador) {
      list.add(
        DropdownMenuItem(
          child: Text(operador.name ?? ''),
          value: operador.id,
        ),
      );
    });
    return list;
  }

  Widget _textFielEnt(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        onTap: () {
          _selectDateTime(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: con.timeController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Selecciona una fecha y hora',
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.av_timer_rounded),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        con.timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(pickedDateTime);
      }
    }
  }
  Widget _textFielStatus() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Obx(() {
        List<DropdownMenuItem<String>> items = [];

        // Si no hay registros, solo mostrar 'INICIO'
        if (!con.hasRecords.value) {
          items.add(DropdownMenuItem(
            child: Text('INICIO'),
            value: 'INICIO',
          ));
        } else {
          // Si hay registros, aplicar la lógica anterior
          if (con.lastState.value != 'SUSPENDIDO') {
            items.add(DropdownMenuItem(
              child: Text('SUSPENDIDO'),
              value: 'SUSPENDIDO',
            ));
          }

          if (con.lastState.value == 'SUSPENDIDO') {
            items.add(DropdownMenuItem(
              child: Text('REANUDAR'),
              value: 'REANUDAR',
            ));
          }

          items.add(DropdownMenuItem(
            child: Text('SIG. PROCESO'),
            value: 'SIG. PROCESO',
          ));
        }

        return DropdownButtonFormField<String>(
          icon: Icon(Icons.arrow_drop_down_circle, color: Colors.grey),
          decoration: InputDecoration(
            hintText: 'Selecciona el status',
            prefixIcon: Icon(Icons.handyman_outlined),
          ),
          items: items,
          onChanged: (value) {
            con.selectedStatus.value = value!;
            con.estadoController.text = value;
          },
        );
      }),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return Container(
      //width: double.infinity,
      margin: EdgeInsets.only(top: 5, right:30, bottom: 10 ),
      child: ElevatedButton(
        onPressed: () => con.createTiempo(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        child: Text(
          'GUARDAR',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buttonBack() {
    return SafeArea( // deja espacio de la barra del telefono
      child: Container(
        margin: EdgeInsets.only(left: 20),
        child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 30,
            )
        ),
      ),
    );
  }
  Widget _textFieldComent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: con.comentController,
        keyboardType: TextInputType.text,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Comentarios',
            prefixIcon: Container(
                child: Icon(Icons.description)
            )
        ),
      ),
    );
  }
}
