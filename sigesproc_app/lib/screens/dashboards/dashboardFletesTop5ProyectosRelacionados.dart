import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopProjectsDashboard extends StatefulWidget {
  @override
  _TopProjectsDashboardState createState() => _TopProjectsDashboardState();
}

class _TopProjectsDashboardState extends State<TopProjectsDashboard> {
  late Future<List<TopProyectosRelacionadosViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior =
      TooltipBehavior(enable: true); // Habilitar tooltip

  @override
  void initState() {
    super.initState();
    // Fetch the dynamic data for the top 5 projects with the most fletes
    _dashboardData = DashboardService.listarProyectosRelacionados();
  }

  // Función para calcular el porcentaje
  String calculatePercentage(int value, int total) {
    return ((value / total) * 100).toStringAsFixed(2) + "%";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171717),
      child: FutureBuilder<List<TopProyectosRelacionadosViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
                child: Text('Error al cargar los datos',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          } else if (snapshot.hasData) {
            // Calcular el total de fletes y asegurar que el valor sea entero
            int totalFletes = snapshot.data!.fold(
                0,
                (int sum, item) =>
                    sum + (item.totalFletesDestinoProyecto?.toInt() ?? 0));

            return _buildPieChart(snapshot.data!, totalFletes);
          } else {
            return Center(
                child: Text('No hay datos disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          }
        },
      ),
    );
  }

  Widget _buildPieChart(
      List<TopProyectosRelacionadosViewModel> data, int totalFletes) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: const Color(0xFF171717),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Top 5 Proyectos con más Fletes Recibidos',
                  style: TextStyle(
                    color: const Color(0xFFFFF0C6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 150, // Adjust chart height as needed
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                    tooltipBehavior: _tooltipBehavior, // Activar tooltip
                    series: <CircularSeries>[
                      PieSeries<TopProyectosRelacionadosViewModel, String>(
                        dataSource: data,
                        xValueMapper:
                            (TopProyectosRelacionadosViewModel item, _) =>
                                item.proy_Nombre ?? '',
                        yValueMapper: (TopProyectosRelacionadosViewModel item,
                                _) =>
                            item.totalFletesDestinoProyecto?.toInt() ??
                            0, // Convertir a int
                        dataLabelMapper:
                            (TopProyectosRelacionadosViewModel item, _) {
                          final porcentaje = calculatePercentage(
                              item.totalFletesDestinoProyecto?.toInt() ?? 0,
                              totalFletes);
                          return '${item.proy_Nombre} ($porcentaje)'; // Mostrar el porcentaje en el label
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 8),
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                        pointColorMapper:
                            (TopProyectosRelacionadosViewModel item, _) {
                          List<Color> colors = [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.purple,
                            Colors.orange,
                          ];
                          int index = item.proy_Nombre.hashCode % colors.length;
                          return colors[index];
                        },
                        explode: true,
                        explodeIndex: 0,
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
