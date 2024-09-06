import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para formatear números
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart'; // Para la moneda global

class DashboardVentaBienRaiz extends StatefulWidget {
  @override
  _DashboardVentaBienRaizState createState() => _DashboardVentaBienRaizState();
}

class _DashboardVentaBienRaizState extends State<DashboardVentaBienRaiz> {
  late Future<List<DashboardViewModel>> _dashboardData; // Lista de datos
  String _abreviaturaMoneda = "L"; // Abreviatura de moneda por defecto

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.ventamensualbienraiz(); // Llamada al servicio que retorna una lista
    _obtenerAbreviaturaMoneda();
  }

  // Método para obtener la abreviatura de la moneda global
  Future<void> _obtenerAbreviaturaMoneda() async {
    _abreviaturaMoneda = (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {});
  }

  // Método para formatear el número con comas y puntos
 String formatNumber(double value) {
    // Para asegurarse de que las comas estén en miles y el punto sea decimal
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US'); // Formato correcto para comas en miles y punto en decimales
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF171717),
          padding: EdgeInsets.all(8.0),
          child: FutureBuilder<List<DashboardViewModel>>(
            future: _dashboardData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFE645),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error al cargar los datos',
                      style: TextStyle(color: Colors.white)),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return _buildDashboardContent(snapshot.data!.first, constraints);
              } else {
                return Center(
                  child: Text('No hay datos disponibles',
                      style: TextStyle(color: Colors.white)),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(
      DashboardViewModel data, BoxConstraints constraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícono y título con mejor estilo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.real_estate_agent, color: Colors.white, size: 20), // Icono más pequeño
            SizedBox(width: 8),
            Text(
              'Bienes Raíces',
              style: TextStyle(color: Colors.white, fontSize: 18), // Título más pequeño
            ),
          ],
        ),
        SizedBox(height: 15),

        // Mostrar la cantidad de bienes vendidos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: Colors.greenAccent, size: 24), // Icono más pequeño
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centrar el contenido
              children: [
                Text(
                  'Cantidad Vendida:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '${data.cantidadVendidosMes}',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 15),

        // Mostrar el total de ventas con formato de moneda
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, color: Colors.yellowAccent, size: 24), // Icono más pequeño
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centrar el contenido
              children: [
                Text(
                  'Total Ventas:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '$_abreviaturaMoneda ${formatNumber(data.totalVentasMes ?? 0.0)}',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
