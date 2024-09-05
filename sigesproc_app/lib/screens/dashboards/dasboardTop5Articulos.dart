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
            return Center(child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            // Agregar un print para verificar los datos recibidos
snapshot.data!.forEach((item) {
  print('Artículo: ${item.articulo}, Total Compra: ${item.totalCompra}');
  
  // Verifica que totalCompra sea numérico
  if (item.totalCompra is! num) {
    print('Error: totalCompra no es numérico para el artículo ${item.articulo}');
  }

  // Verifica que articulo sea un String
  if (item.articulo is! String) {
    print('Error: articulo no es un String');
  }
});


            return _buildHorizontalBarChartContainer(snapshot.data!);
          } else {
            return Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Widget _buildHorizontalBarChartContainer(List<DashboardViewModel> data) {
    return SingleChildScrollView(
      child: Padding(
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 150, // Ajusta la altura según sea necesario
                  child: SfCartesianChart(
                    isTransposed: true, // Gráfico de barras horizontales
                    primaryXAxis: NumericAxis(
                      labelStyle: TextStyle(color: Colors.white),
                      title: AxisTitle(
                        text: 'Total Compra',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    primaryYAxis: CategoryAxis(
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    series: <ChartSeries>[
BarSeries<DashboardViewModel, String>(
  dataSource: [
    DashboardViewModel(articulo: "Producto A", totalCompra: 100.0),
    DashboardViewModel(articulo: "Producto B", totalCompra: 200.0),
  ],
  xValueMapper: (DashboardViewModel item, _) => item.articulo ?? '',
  yValueMapper: (DashboardViewModel item, _) => item.totalCompra ?? 0.0,
  color: Colors.blueAccent,
  dataLabelSettings: DataLabelSettings(
    isVisible: true,
    textStyle: TextStyle(color: Colors.white),
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
