import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para manejar el formato de números

class Top5BancosDashboard extends StatefulWidget {
  @override
  _Top5BancosDashboardState createState() => _Top5BancosDashboardState();
}

class _Top5BancosDashboardState extends State<Top5BancosDashboard> {
  late Future<List<BancoAcreditacionesViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(
      enable: true, format: 'point.x : point.y'); // Habilitar tooltip

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarTop5Bancos();
  }

  // Función para calcular porcentaje
  String calculatePercentage(int value, int total) {
    return ((value / total) * 100).toStringAsFixed(2) + "%";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF171717),
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder<List<BancoAcreditacionesViewModel>>(
            future: _dashboardData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFE645),
                  ),
                );
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(
                  child: Text(
                    'Error: ENTRA AQUI',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                // Sumar todas las acreditaciones
                int totalAcreditaciones = snapshot.data!.fold(
                    0, (sum, item) => sum + (item.numeroAcreditaciones ?? 0));

                return _buildPieChart(
                    snapshot.data!, constraints, totalAcreditaciones);
              } else {
                return Center(
                  child: Text(
                    'No hay datos disponibles',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPieChart(List<BancoAcreditacionesViewModel> data,
      BoxConstraints constraints, int totalAcreditaciones) {
    return Center(
      child: Container(
        height: constraints.maxHeight * 0.97,
        width: constraints.maxWidth * 0.97,
        child: SfCircularChart(
          title: ChartTitle(
            text: 'Top 5 Bancos con más Acreditaciones en Nómina',
            textStyle: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 11), // Reducir tamaño del título
          ),
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom, // Mover la leyenda al fondo
            textStyle: TextStyle(
                color: Color(0xFFFFF0C6), fontSize: 11), // Tamaño reducido
          ),
          tooltipBehavior:
              _tooltipBehavior, // Habilitar tooltip para mostrar cantidad
          series: <CircularSeries>[
            PieSeries<BancoAcreditacionesViewModel, String>(
              dataSource: data,
              xValueMapper: (BancoAcreditacionesViewModel item, _) =>
                  item.banco ?? '',
              yValueMapper: (BancoAcreditacionesViewModel item, _) =>
                  (item.numeroAcreditaciones ?? 0)
                      .toDouble(), // Convertir a double
              dataLabelMapper: (BancoAcreditacionesViewModel item, _) {
                // Calcular el porcentaje y mostrarlo
                return '${item.banco}\n${calculatePercentage(item.numeroAcreditaciones ?? 0, totalAcreditaciones)}';
              },
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition
                    .outside, // Etiquetas afuera del gráfico
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 10), // Tamaño y estilo de texto
              ),
              explode: true, // Explosión de secciones
              explodeAll: true,
              radius: '97%', // Ajuste del tamaño del gráfico
              pointColorMapper: (BancoAcreditacionesViewModel item, index) {
                // Asignar colores personalizados con opacidad
                List<Color> colors = [
                  Colors.blue,
                  Colors.green,
                  Colors.red,
                  Colors.purple,
                  Colors.orange,
                ];
                return colors[index % colors.length];
              },
            ),
          ],
        ),
      ),
    );
  }
}
