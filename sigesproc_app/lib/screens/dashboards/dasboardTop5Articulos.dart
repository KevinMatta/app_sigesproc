import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopArticlesDashboard extends StatefulWidget {
  @override
  _TopArticlesDashboardState createState() => _TopArticlesDashboardState();
}

class _TopArticlesDashboardState extends State<TopArticlesDashboard> {
  late Future<List<DashboardViewModel>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarTop5ArticulosComprados();
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
    // For demonstration purposes, we'll simulate another data set
    List<double> engagementRate = [4.2, 10.9, 14.9, 29.3, 33.2, 7.4];

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
                  'Top 5 Artículos más Comprados y Tasa de Compromiso',
                  style: TextStyle(
                    color: const Color(0xFFFFF0C6),
                    fontSize: 12, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0), // Reduced spacing
                Container(
                  height: 200, // Adjusted height for the comparison chart
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 8), // Smaller text
                      title: AxisTitle(
                        text: 'Artículo',
                        textStyle: const TextStyle(
                            color: Colors.white, fontSize: 8), // Smaller text
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 8), // Smaller text
                      title: AxisTitle(
                        text: 'Total Compra / Tasa de Compromiso',
                        textStyle: const TextStyle(
                            color: Colors.white, fontSize: 8), // Smaller text
                      ),
                    ),
                    legend: Legend(isVisible: true),
                    series: <ChartSeries>[
                      BarSeries<DashboardViewModel, String>(
                        name: 'Total Compra',
                        dataSource: data,
                        xValueMapper: (DashboardViewModel item, _) =>
                            item.articulo ?? '',
                        yValueMapper: (DashboardViewModel item, _) =>
                            item.totalCompra ?? 0.0,
                        color: Colors.redAccent, // Adjust the color to red
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 8), // Smaller text
                        ),
                      ),
                      BarSeries<DashboardViewModel, String>(
                        name: 'Tasa de Compromiso',
                        dataSource: data,
                        xValueMapper: (DashboardViewModel item, int index) =>
                            item.articulo ?? '',
                        yValueMapper: (DashboardViewModel item, int index) =>
                            engagementRate[index], // Using simulated data
                        color: Colors.cyanAccent, // Adjust the color to cyan
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
