import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para manejar formato de números y monedas
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';

class TopProjectsBudgetDashboard extends StatefulWidget {
  @override
  _TopProjectsBudgetDashboardState createState() =>
      _TopProjectsBudgetDashboardState();
}

class _TopProjectsBudgetDashboardState
    extends State<TopProjectsBudgetDashboard> {
  late Future<List<DashboardViewModel>> _dashboardData;
  String _abreviaturaMoneda = "L"; // Valor predeterminado de moneda

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Función asincrónica para cargar la abreviatura de moneda
  Future<void> _loadData() async {
    _dashboardData = DashboardService.listarTop5ProyectosMayorPresupuesto();
    _abreviaturaMoneda = (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {}); // Refresca el widget para reflejar la nueva abreviatura
  }

  // Función para formatear los números con comas y punto decimal
  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171717),
      child: FutureBuilder<List<DashboardViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar los datos',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          } else if (snapshot.hasData) {
            return _buildComparisonBarChartContainer(snapshot.data!);
          } else {
            return Center(
                child: Text('No hay datos disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          }
        },
      ),
    );
  }

  Widget _buildComparisonBarChartContainer(List<DashboardViewModel> data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: const Color(0xFF171717),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Top 5 Proyectos con Mayor Presupuesto',
                  style: TextStyle(
                    color: const Color(0xFFFFF0C6),
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0), // Reduced spacing
                Container(
                  width: double.infinity, // Make sure it fills the width
                  height: 200, // Adjusted height for the comparison chart
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 8), // Smaller text
                      title: AxisTitle(
                        text: 'Proyecto',
                        textStyle: const TextStyle(
                            color: Colors.white, fontSize: 8), // Smaller text
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 8), // Smaller text
                    ),
                    legend: Legend(isVisible: true),
                    series: <ChartSeries>[
                      BarSeries<DashboardViewModel, String>(
                        name: ' ',
                        dataSource: data,
                        xValueMapper: (DashboardViewModel item, _) =>
                            item.proy_Nombre ?? '',
                        yValueMapper: (DashboardViewModel item, _) =>
                            item.presupuestoTotal ?? 0.0,
                        pointColorMapper: (DashboardViewModel item, index) {
                          // Asignar diferentes colores a cada barra
                          List<Color> barColors = [
                            Colors.blueAccent,
                            Colors.redAccent,
                            Colors.greenAccent,
                            Colors.orangeAccent,
                            Colors.purpleAccent
                          ];
                          return barColors[index % barColors.length];
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 8),
                          // Muestra el valor con la abreviatura de moneda y formato adecuado
                          labelAlignment: ChartDataLabelAlignment.middle,
                        ),
                        dataLabelMapper: (DashboardViewModel item, _) {
                          // Formatear y mostrar el presupuesto con la abreviatura de moneda
                          return '$_abreviaturaMoneda ${formatNumber(item.presupuestoTotal ?? 0.0)}';
                        },
                      ),
                    ],
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
