import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return Container( // Reemplazamos Scaffold por un simple Container para hacerlo más pequeño
      color: Colors.black,
      child: FutureBuilder<List<DashboardViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            // Agregamos un print para ver los datos en consola
            snapshot.data!.forEach((item) {
              print('Artículo: ${item.articulo}, Total Compra: ${item.totalCompra}');
            });
            return _buildPieChartContainer(snapshot.data!);
          } else {
            return Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }







Widget _buildPieChartContainer(List<DashboardViewModel> data) {
  return Padding(
    padding: const EdgeInsets.all(8.0), // Reducimos el padding para hacerlo más pequeño
    child: Card(
      color: Color(0xFF171717),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reducimos el padding interno también
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centramos verticalmente
          crossAxisAlignment: CrossAxisAlignment.center, // Centramos horizontalmente
          children: [
            Text(
              'Top 5 Artículos más Comprados',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 10, 
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0), // Reducimos el espacio entre el título y el gráfico
            Container(
              height: 150, // Fijamos una altura pequeña para el gráfico
              child: Center(
                child: PieChart(
                  PieChartData(
                    sections: _createPieChartSections(data),
                    sectionsSpace: 1, // Espacio entre secciones
                    centerSpaceRadius: 0, // Reducimos el tamaño del centro para hacer más pequeño el gráfico
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (PieTouchResponse? pieTouchResponse) {
                        // Manejo de interacciones si es necesario
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}










  List<PieChartSectionData> _createPieChartSections(List<DashboardViewModel> data) {
    final colors = [
      Color(0xFF5074A0), // Color 1
      Color(0xFF293C50), // Color 2
      Color(0xFF24374B), // Color 3
      Color(0xFF1F3144), // Color 4
      Color(0xFF162433), // Color 5
    ];

    return data.asMap().entries.map((entry) {
      int index = entry.key;
      DashboardViewModel item = entry.value;
      final double fontSize = 8.0; // Reducimos aún más el tamaño de la fuente
      final double radius = 40.0; // Hacemos más pequeño el radio de las secciones

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.totalCompra != null ? item.totalCompra! : 0, // Aseguramos que el valor no sea nulo
        title: '${item.articulo} (${item.totalCompra?.toStringAsFixed(1)})',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();
  }
}

Widget _buildTopArticlesTab() {
  return Container(
    color: Colors.black,
    padding: const EdgeInsets.all(4.0), // Ajustamos padding para hacer todo más pequeño
    child: TopArticlesDashboard(), // Mostramos el gráfico de pastel con título
  );
}
