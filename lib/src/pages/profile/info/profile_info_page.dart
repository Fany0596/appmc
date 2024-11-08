import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:maquinados_correa/src/pages/profile/info/profile_info_controller.dart';

class ProfileInfoPage extends StatelessWidget {

  ProfileInfoController con = Get.put(ProfileInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx (() =>  SingleChildScrollView(
        child: Stack(
          children: [
            Column(
                 // posiciona elementos uno sobre otro
                children: [
                  _backGroundCover(context),]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // posiciona elementos uno sobre otro
              children: [
               _encabezado(context),
               _buttonBack(),
               _imageUser(context),
               _boxForm(context),

              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Obx(() => Stack( // posiciona elementos uno sobre otro
  //        children: [
  //         _backGroundCover(context),
  //         _boxForm(context),
  //         _buttonBack(),
  //         _imageUser(context),
  //         _encabezado(context),
  //        ],
  //     )),
  //   );
  // }


// boton de regreso
  Widget _buttonBack() {
    return SafeArea( // deja espacio de la barra del telefono
      child: Container(
        //margin: EdgeInsets.only( top: 5),
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
  Widget _backGroundCover(BuildContext context){ //build context para porcentaje
    return Container(
        width: double.infinity,  //ancho de imagen
        height: MediaQuery.of(context).size.height *0.28, //alto de imagen
        color: Colors.grey
    );
  }

  // caja de datos
  // Widget _boxForm(BuildContext context) {
  //   return Positioned(
  //     top: MediaQuery.of(context).size.height * 0.45,
  //     left: 50,
  //     right: 40,
  //     child: Container(
  //       height: MediaQuery.of(context).size.height * 0.30,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black54,
  //             blurRadius: 15,
  //             offset: Offset(0, 0.085),
  //           ),
  //         ],
  //       ),
  //         child: Column(
  //           children: [
  //             _textYourInfo(),
  //             _email(),
  //             _buttonUpdate(context),
  //           ],
  //         ),
  //       ),
  //   );
  // }
  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.40,
      margin: EdgeInsets.only( left: 50, right: 40),
      //top: MediaQuery.of(context).size.height*0.37,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset (0,0.085)
            )
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textYourInfo(),
            _email(),
            _buttonUpdate(context),
          ],
        ),
      ),
    );
  }
  Widget _textYourInfo() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text('${con.user.value.name ?? ''}  ${con.user.value.lastname}',),
        subtitle: Text('Nombre de usuario'),
      ),
    );
  }

  Widget _email() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: ListTile(
        leading: Icon(Icons.email),
        title: Text(con.user.value.email ?? ''),
        subtitle: Text('Email'),
      ),
    );
  }


  // boton ACTUALIZAR DATOS
  Widget _buttonUpdate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
          onPressed: () => con.goToProfileUpdate(),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15)
          ),
          child: Text (
            'ACTUALIZAR DATOS',
            style: TextStyle(
              color: Colors.white,
            ),
          )
      ),
    );
  }
  Widget _buttonRoles() {
    return Container(
      margin: EdgeInsets.only(right: 8 ),
      alignment: Alignment.topRight,
      child: IconButton(
          onPressed: () => con.goToRoles(),
          icon: Icon(
            Icons.supervised_user_circle,
            color: Colors.white,
            size: 30,
          )
      ),
    );
  }
  Widget _buttonSingOut() {
    return SafeArea( // deja espacio de la barra del telefono
      child: Container(
        margin: EdgeInsets.only(right: 8 ),
        alignment: Alignment.topRight,
        child: IconButton(
            onPressed: () => con.signOut(),
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.white,
              size: 30,
            )
        ),
      ),
    );
  }
// imagen logo
  Widget _imageUser(BuildContext context){
    return SafeArea(
        child: Container(
          alignment: Alignment.topCenter,
         //margin: EdgeInsets.only(top:5),
          child: CircleAvatar(
            backgroundImage:  con.user.value.image != null
            ? NetworkImage(con.user.value.image!)
            :AssetImage('assets/img/LOGO1.png') as ImageProvider,
            radius: 110,
            backgroundColor: Colors.transparent,
          ),
        )
    );

  }
  Widget _encabezado(BuildContext context) {
    return Container(
      //margin: EdgeInsets.only(top: 15),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //alignment: Alignment.topLeft,
          children: [Image.asset(
            'assets/img/LOGO1.png',
            width: 100, //ancho de imagen
            height: 100, //alto de imagen
          ),
          ]
      ),
    );
  }
}