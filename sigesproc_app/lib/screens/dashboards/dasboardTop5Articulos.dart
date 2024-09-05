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
                  print(
                      "No hay suficientes artículos para mostrar los 5 más comprados.");
                }

                return _buildPieChart(snapshot.data!, constraints);
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

  Widget _buildPieChart(
      List<DashboardViewModel> data, BoxConstraints constraints) {
    return Center(
      child: Container(
        height: constraints.maxHeight * 0.95, // Aumentar el tamaño del gráfico
        width: constraints.maxWidth * 0.95,
        child: SfCircularChart(
          title: ChartTitle(
            text: 'Top 5 Artículos más Comprados',
            textStyle: TextStyle(
                color: Colors.white, fontSize: 12), // Reducir tamaño del título
          ),
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom, // Mover la leyenda al fondo
            textStyle:
                TextStyle(color: Colors.white, fontSize: 10), // Tamaño reducido
          ),
          series: <CircularSeries>[
            PieSeries<DashboardViewModel, String>(
              dataSource: data,
              xValueMapper: (DashboardViewModel item, _) => item.articulo ?? '',
              yValueMapper: (DashboardViewModel item, _) =>
                  item.totalCompra ?? 0.0,
              dataLabelMapper: (DashboardViewModel item, _) =>
                  '${item.articulo}\n${item.totalCompra}', // Mostrar el nombre arriba del valor
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition
                    .outside, // Etiquetas afuera del gráfico
                textStyle: TextStyle(
                    color: Colors.white, fontSize: 10), // Tamaño más pequeño
              ),
              explode: true, // Destacar las secciones
              explodeAll: true,
              radius: '95%', // Hacer el gráfico más grande
            )
          ],
        ),
      ),
    );
  }
}
