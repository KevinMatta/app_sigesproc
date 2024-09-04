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
    return Container(
      color: Colors.black,
      child: FutureBuilder<List<DashboardViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            // Filtrar los datos que tienen totalCompra mayor que 0
            List<DashboardViewModel> filteredData = snapshot.data!.where((item) => item.totalCompra != null && item.totalCompra! > 0).toList();
            
            if (filteredData.isEmpty) {
              return Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)));
            }

            return _buildPieChartContainer(filteredData);
          } else {
            return Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Widget _buildPieChartContainer(List<DashboardViewModel> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Color(0xFF171717),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Top 5 Artículos más Comprados',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                height: MediaQuery.of(context).size.height * 0.3, // Ajuste de altura dinámico para pantallas pequeñas
                child: Center(
                  child: PieChart(
                    PieChartData(
                      sections: _createPieChartSections(data),
                      sectionsSpace: 1,
                      centerSpaceRadius: 0,
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
      Color.fromARGB(255, 50, 74, 100),
      Color.fromARGB(255, 41, 60, 80),
      Color.fromARGB(255, 36, 55, 75),
      Color.fromARGB(255, 31, 49, 68),
      Color(0xFF162433),
    ];

    return data.asMap().entries.map((entry) {
      int index = entry.key;
      DashboardViewModel item = entry.value;
      final double fontSize = 5.0; 
      final double radius = 40.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.totalCompra!.toDouble(),
        title: '${item.articulo} (${item.totalCompra})',
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
