import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class Top5BancosDashboard extends StatefulWidget {
  @override
  _Top5BancosDashboardState createState() => _Top5BancosDashboardState();
}

class _Top5BancosDashboardState extends State<Top5BancosDashboard> {
  late Future<List<DashboardViewModel>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarTop5Bancos();
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
        height: constraints.maxHeight * 0.97, // Aumentar el tamaño del gráfico
        width: constraints.maxWidth * 0.97,
        child: SfCircularChart(
          title: ChartTitle(
            text: 'Top 5 Bancos con mas Acreditaciones en Nómina',
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
          series: <CircularSeries>[
            PieSeries<DashboardViewModel, String>(
              dataSource: data,
              xValueMapper: (DashboardViewModel item, _) => item.banco ?? '',
              yValueMapper: (DashboardViewModel item, _) =>
                  item.numeroAcreditaciones ?? 0.0,
              dataLabelMapper: (DashboardViewModel item, _) =>
                  '${item.banco}\n${item.numeroAcreditaciones}', // Mostrar el nombre arriba del valor
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition
                    .outside, // Etiquetas afuera del gráfico
                textStyle: TextStyle(
                    color: Colors.white, fontSize: 10), // Tamaño más pequeño
              ),
              explode: true, // Destacar las secciones
              explodeAll: true,
              radius: '97%', // Hacer el gráfico más grande
            )
          ],
        ),
      ),
    );
  }
}
