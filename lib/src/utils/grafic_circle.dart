import 'dart:ui';

class GDPData {
  GDPData (
      this.continent,
      this.gdp,
      this.color
      );
  final String continent;
  final double gdp;
  final Color color;
}
// Clase para almacenar los datos del gráfico
class SalesData {
  SalesData({required this.month, required this.completed, required this.rejected, required this.rework});
  final String month; // El mes en formato 'YYYY-MM'
  final double completed; // Piezas completadas
  final double rejected; // Piezas con rechazo
  final double rework; // Piezas con retrabajo
}
class CotData {
  CotData({required this.cliente, required this.solicitada, required this.aceptada});
  final String cliente;
  final double solicitada;  // Cambiar a double
  final double aceptada;    // Cambiar a double
}