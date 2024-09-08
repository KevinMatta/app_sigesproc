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

  @override
  void initState() {
    super.initState();
    // Fetch the dynamic data for the top 5 projects with the most fletes
    _dashboardData = DashboardService.listarProyectosRelacionados();
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
            // Log the data in console
            print('Data fetched: ${snapshot.data}');

            // Log individual elements for better visibility
            snapshot.data!.forEach((item) {
              print(
                  'Proyecto: ${item.proy_Nombre}, Fletes: ${item.totalFletesDestinoProyecto}');
            });

            return _buildPieChart(snapshot.data!);
          } else {
            return Center(
                child: Text('No hay datos disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          }
        },
      ),
    );
  }

  Widget _buildPieChart(List<TopProyectosRelacionadosViewModel> data) {
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
                    series: <CircularSeries>[
                      PieSeries<TopProyectosRelacionadosViewModel, String>(
                        dataSource: data,
                        xValueMapper: (TopProyectosRelacionadosViewModel item, _) =>
                            item.proy_Nombre ?? '',
                        yValueMapper: (TopProyectosRelacionadosViewModel item, _) =>
                            item.totalFletesDestinoProyecto ?? 0.0,
                        dataLabelMapper: (TopProyectosRelacionadosViewModel item, _) =>
                            '${item.proy_Nombre} (${item.totalFletesDestinoProyecto} fletes)',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 8),
                          labelPosition: ChartDataLabelPosition
                              .outside, // Ensure labels are outside
                        ),
                        pointColorMapper: (TopProyectosRelacionadosViewModel item, _) {
                          List<Color> colors = [
                            Colors.redAccent,
                            Colors.greenAccent,
                            Colors.blueAccent,
                            Colors.orangeAccent,
                            Colors.purpleAccent,
                          ];
                          int index = item.proy_Nombre.hashCode % colors.length;
                          return colors[index];
                        },
                        explode: true, // This enables the exploding effect
                        explodeIndex:
                            0, // You can choose which slice to explode or explode all
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
