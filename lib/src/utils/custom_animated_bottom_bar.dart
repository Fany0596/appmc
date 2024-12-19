import 'package:flutter/material.dart';  // Importa el paquete de widgets básicos de flutter
import 'package:flutter/widgets.dart';  // Importa widgets adicionales de flutter

class CustomAnimatedBottomBar extends StatelessWidget {  // Define un widget personalizado de barra de navegación inferior animada

  CustomAnimatedBottomBar({  // Constructor del widget, acepta varios parámetros con valores predeterminados
    Key? key,
    this.selectedIndex = 0,  //Ïndice predeterminado de la pestaña seleccionada
    this.showElevation = true, // Si muestra una sombra de elevación o no
    this.iconSize = 20, // Tamaño de los íconos
    this.backgroundColor,  // Color de fondo de la barra
    this.itemCornerRadius = 50, // Radio de los bordes de cada elemto
    this.containerHeight = 56, // Altura del contenedor de la barra
    this.animationDuration = const Duration(milliseconds: 270),  // Duración de la animación
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween, // Alineación de los elementos
    required this.items,  // Lista de elementos de la barra (requiere al menos 2)
    required this.onItemSelected,  // Callback cuando se selecciona un elemento
    this.curve = Curves.linear,  // Curva de animación
  }) : assert(items.length >= 2 && items.length <= 6),  // Asegura que haya entre 2 y 6 elementos
        super(key: key);

  final int selectedIndex;  //Índice del elemento seleccionado
  final double iconSize; // Tamaño del ícono
  final Color? backgroundColor; // Color de fondo
  final bool showElevation;  // Indica si hay sombra de elevación
  final Duration animationDuration;  // Duración de la animación de selección
  final List<BottomNavyBarItem> items;  // Lista de elementos de la barra
  final ValueChanged<int> onItemSelected;  // Calback al seleccionar un elemento
  final MainAxisAlignment mainAxisAlignment; // Alineación de los elementos
  final double itemCornerRadius; // Radio de los bordes de cada elemento
  final double containerHeight;  // Altura del contenedor de la barra
  final Curve curve; // Curva de la animación

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).bottomAppBarColor;  // Asigan el color de fondo de la barra o usa el color predeterminado del tema

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),  // Margen alrededor del contenedor
      decoration: BoxDecoration(
        color: bgColor,  //Color de fondo
        borderRadius: BorderRadius.circular(1),  // Radio de borde de 50
        boxShadow: [
          if (showElevation)  // Agrega sombra solo si showElevation es verdadero
            const BoxShadow(
              color: Colors.black, // Color de la sombra
              blurRadius: 3,  // Difuminado de la sombra
            ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,  // Ancho completo del contenedor
          height: containerHeight,  // Altura del contenedor
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),  // Relleno
          child: Row(
            mainAxisAlignment: mainAxisAlignment,  // Alineación de los elementos
            children: items.map((item) {  // Mapea cada elemento en la lista de items
              var index = items.indexOf(item);  // Índice del elemento actual
              return GestureDetector(
                onTap: () => onItemSelected(index),  // Llama al callback con el índice seleccionado
                child: _ItemWidget(
                  item: item,  // Elemento actual
                  iconSize: iconSize,  // Tamaño del ícono
                  isSelected: index == selectedIndex,  // Determina si esta seleccionado
                  backgroundColor: bgColor,  // Color de fondo
                  itemCornerRadius: itemCornerRadius, // Radio de los bordes del elemento
                  animationDuration: animationDuration,  // Duración de la animación
                  curve: curve,  // Curva de la animación
                ),
              );
            }).toList(),  // Convierte los elementos en nuna lista de widgets
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {  // Wiget que representa un elemento individual en la barra de navegación
  final double iconSize;  // Tamaño del ícono
  final bool isSelected;  // Indica si el elemento está seleccionado
  final BottomNavyBarItem item; // Elemento de la barra
  final Color backgroundColor;  // Color de fondo del elemento
  final double itemCornerRadius;  // Radio de lo bordes del elemento
  final Duration animationDuration;  // Duración de la animación
  final Curve curve;  // Curva de la animación

  const _ItemWidget({
    Key? key,
    required this.item,  // El elemento de la barra de navegacion
    required this.isSelected,  // Si esta seleccionado
    required this.backgroundColor, // Color de fondo del contenedor
    required this.animationDuration,  // Duración de la animación
    required this.itemCornerRadius, // Radio de los bordes
    required this.iconSize,  // Tamaño del ícono
    this.curve = Curves.linear,  // Curva de la animación por defecto lineal
  })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true, // Define el widget como contenedor
      selected: isSelected,  // Indica si el elemento está seleccionado
      child: AnimatedContainer(
        width: isSelected ? 130 : 50,  // Ancho segun selleción
        height: double.maxFinite,  // Altura completa
        duration: animationDuration,  // Duración de la animación de ancho
        curve: curve,  // Curva de la animación
        decoration: BoxDecoration(
          color:
          isSelected ? item.activeColor.withOpacity(0.2) : backgroundColor,  // Fondo segun selección
          borderRadius: BorderRadius.circular(itemCornerRadius), // Bordes redondeados
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Permite desplazamiento horizontal
          physics: NeverScrollableScrollPhysics(), // Evita que se desplace
          child: Container(
            width: isSelected ? 130 : 50,  // Ancho segun selección
            padding: EdgeInsets.symmetric(horizontal: 8),  // Relleno horizontal
            child: Row(
              mainAxisSize: MainAxisSize.max,  // Tamaño maximo en el eje principal
              mainAxisAlignment: MainAxisAlignment.start, // Alineación al inicio
              crossAxisAlignment: CrossAxisAlignment.center,  // Alineación al centro vertical
              children: <Widget>[
                IconTheme(
                  data: IconThemeData(
                    size: iconSize, // Tamaño del ícono
                    color: isSelected  // Color segun selección
                        ? item.activeColor.withOpacity(1)
                        : item.inactiveColor == null // Color inactivo si no esta seleccionado
                        ? item.activeColor
                        : item.inactiveColor,
                  ),
                  child: item.icon, // Ícono del elemento
                ),
                if (isSelected)  // Muestra el texto solo si está seleccionado
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4), // Relleno del texto
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: item.activeColor, // Color del texto activo
                          fontWeight: FontWeight.bold, // Estilo de texto en negrita
                        ),
                        maxLines: 1, // Máximo 1 línea de texto
                        textAlign: item.textAlign,  // Alineción del texto
                        child: item.title,  // Título del elemento
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class BottomNavyBarItem {  // Clase que define un elemento individual en la barra de navegación

  BottomNavyBarItem({
    required this.icon,  // Ícono del elemento
    required this.title,  // Título del elemento
    this.activeColor = Colors.grey,  // Color activo predeterminado
    this.textAlign,  // Alineación del texto
    this.inactiveColor,  // Color inactivo
  });

  final Widget icon;  // Widget ícon
  final Widget title; // Widget título
  final Color activeColor;  // Color cuando está seleccionado
  final Color? inactiveColor;  // Color cuando no está seleccionado
  final TextAlign? textAlign;  //Alineación del texto

}