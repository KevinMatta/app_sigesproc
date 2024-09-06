import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopProveedoresDashboard extends StatefulWidget {
  @override
  _TopProveedoresDashboardState createState() => _TopProveedoresDashboardState();
}

class _TopProveedoresDashboardState extends State<TopProveedoresDashboard> {
  late Future<List<DashboardViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarTop5Proveedores();
  }

  String truncateText(String text, {int maxLength = 10}) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF171717),
          padding: EdgeInsets.all(16.0),
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
              } else if (snapshot.hasData) {
                if (snapshot.data!.length < 5) {
                  print("No hay suficientes proveedores para mostrar los 5 más cotizados.");
                }

                return _buildBarChart(snapshot.data!, constraints);
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

  Widget _buildBarChart(
      List<DashboardViewModel> data, BoxConstraints constraints) {
    return Center(
      child: Container(
        height: constraints.maxHeight * 0.75,
        width: constraints.maxWidth * 0.95,
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Top 5 Proveedores más Cotizados',
            textStyle: TextStyle(color: Colors.white, fontSize: 16),
          ),
          primaryXAxis: CategoryAxis(
            labelIntersectAction: AxisLabelIntersectAction.wrap,
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 100, // Ajusta el valor máximo según tus datos
            interval: 10,
            majorGridLines: MajorGridLines(width: 0), // Quitar la cuadrícula del centro
          ),
          tooltipBehavior: _tooltipBehavior, // Habilitar el tooltip
          series: <ChartSeries>[
            BarSeries<DashboardViewModel, String>(
              dataSource: data,
              xValueMapper: (DashboardViewModel item, _) =>
                  truncateText(item.provDescripcion ?? ''), // Truncate the label
              yValueMapper: (DashboardViewModel item, _) =>
                  item.numeroDeCotizaciones ?? 0,
              pointColorMapper: (DashboardViewModel item, index) {
                // Use the same colors from the pie chart
                List<Color> barColors = [
                  Colors.blue.withOpacity(0.7),     // Cemento Portland color
                  Colors.red.withOpacity(0.7),      // Retroexcavadora color
                  Colors.pink.withOpacity(0.7),     // Sierra Caladora color
                  Colors.green.withOpacity(0.7),    // Chaleco color
                  Colors.orange.withOpacity(0.7),   // Cascos color
                ];
                return barColors[index % barColors.length];
              },
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white, fontSize: 10),
              ),
              onPointTap: (pointDetails) {
                final fullName = data[pointDetails.pointIndex!].provDescripcion!;
                _tooltipBehavior.showByIndex(0, pointDetails.pointIndex!);
                // Display tooltip with full name
                print('Full name tapped: $fullName');
              },
            ),
          ],
        ),
      ),
    );
  }
}
