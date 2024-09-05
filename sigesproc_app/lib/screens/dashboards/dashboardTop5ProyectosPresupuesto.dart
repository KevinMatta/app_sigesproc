import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopProjectsBudgetDashboard extends StatefulWidget {
  @override
  _TopProjectsBudgetDashboardState createState() =>
      _TopProjectsBudgetDashboardState();
}

class _TopProjectsBudgetDashboardState
    extends State<TopProjectsBudgetDashboard> {
  late Future<List<DashboardViewModel>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarTop5ProyectosMayorPresupuesto();
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
                    fontSize: 12, // Reduced font size
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
                      // Removed the 'Presupuesto Total' title here to avoid compression
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
                        color: Colors.blueAccent, // Adjust the color to blue
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 8), // Smaller text
                        ),
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
