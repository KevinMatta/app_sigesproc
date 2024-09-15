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
  late Future<List<DashboardBienRaizViewModel>> _dashboardData;
  String _abreviaturaMoneda = "L";

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.ventamensualbienraiz();
    _obtenerAbreviaturaMoneda();
  }

  Future<void> _obtenerAbreviaturaMoneda() async {
    _abreviaturaMoneda = (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {});
  }

  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Obtener tamaño de la pantalla
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          color: const Color(0xFF171717),
          padding: EdgeInsets.all(8.0),
          child: FutureBuilder<List<DashboardBienRaizViewModel>>(
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
                return _buildDashboardContent(snapshot.data!.first, screenWidth);
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
      DashboardBienRaizViewModel data, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.real_estate_agent,
                color: const Color(0xFFFFF0C6), size: screenWidth * 0.05),
            SizedBox(width: 8),
            Text(
              'Bienes Raíces',
              style: TextStyle(
                  color: const Color(0xFFFFF0C6),
                  fontSize: screenWidth * 0.05), // Texto ajustado dinámicamente
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home,
                color: const Color.fromARGB(255, 105, 152, 240),
                size: screenWidth * 0.04), // Tamaño de icono ajustado
            SizedBox(width: 8),
            Text(
              'Cantidad Vendida',
              style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '${data.cantidadVendidosMes}',
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: screenWidth * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money,
                color: Colors.yellowAccent, size: screenWidth * 0.04),
            SizedBox(width: 8),
            Text(
              'Total Ventas',
              style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '$_abreviaturaMoneda ${formatNumber(data.totalVentasMes ?? 0.0)}',
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
