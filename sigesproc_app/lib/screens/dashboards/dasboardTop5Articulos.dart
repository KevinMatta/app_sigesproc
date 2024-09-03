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





List<PieChartSectionData> _createPieChartSections(
    List<DashboardViewModel> data) {

    final colors = [
      Color.fromARGB(255, 50, 74, 100), // Light cream
      Color.fromARGB(255, 41, 60, 80), // Yellow
      Color.fromARGB(255, 36, 55, 75), // Dark blue
      Color.fromARGB(255, 31, 49, 68), // Dark blue
      Color(0xFF162433), // Dark blue
    ];

    return data.asMap().entries.map((entry) {
      int index = entry.key;
      DashboardViewModel item = entry.value;
      final double fontSize = 5.0; // Tamaño de fuente más pequeño y consistente
      final double radius = 40.0; // Tamaño del radio del gráfico de pastel

      return PieChartSectionData(
        color: colors[index % colors.length], // Asigna colores especificados
        value: item.totalCompra!.toDouble(), // Valor de cada sección
        title: '${item.articulo} (${item.totalCompra})', // Etiqueta de cada sección
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
