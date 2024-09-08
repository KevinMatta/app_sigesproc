import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopEstadosDashboard extends StatefulWidget {
  @override
  _TopEstadosDashboardState createState() => _TopEstadosDashboardState();
}

class _TopEstadosDashboardState extends State<TopEstadosDashboard> {
  late Future<List<DepartamentoViewModel>> _dashboardData;

  @override
  void initState() {
    super.initState();
    // Llamada para obtener los datos
    _dashboardData = DashboardService.ProyectosPorDepartamento();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171717),
      child: FutureBuilder<List<DepartamentoViewModel>>(
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
            // Aquí ponemos el console.log (print en Dart)
            snapshot.data!.forEach((item) {
              print(
                  'esta_Nombre: ${item.esta_Nombre}, esta_Codigo: ${item.esta_Nombre}, cantidad_Proyectos: ${item.cantidad_Proyectos}');
            });

            return _buildVerticalBarChart(snapshot.data!);
          } else {
            return Center(
                child: Text('No hay datos disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          }
        },
      ),
    );
  }

  Widget _buildVerticalBarChart(List<DepartamentoViewModel> data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: const Color(0xFF171717),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Top Departamentos por Proyectos',
                  style: TextStyle(
                    color: const Color(0xFFFFF0C6),
                    fontSize: 11, // Tamaño de la fuente del título
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  height: 200, // Ajusta la altura del gráfico
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize:
                              8), // Tamaño de texto para nombres de estados
                      title: AxisTitle(
                        text: 'Estado',
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10), // Tamaño del título del eje X
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize:
                              8), // Tamaño de texto para los valores del eje Y
                      title: AxisTitle(
                        text: 'Cantidad de Proyectos',
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10), // Tamaño del título del eje Y
                      ),
                    ),
                    series: <ChartSeries>[
                      ColumnSeries<DepartamentoViewModel, String>(
                        name: 'Cantidad de Proyectos',
                        dataSource: data,
                        xValueMapper: (DepartamentoViewModel item, _) =>
                            item.esta_Nombre ??
                            '', // Etiqueta con el nombre del estado
                        yValueMapper: (DepartamentoViewModel item, _) =>
                            item.cantidad_Proyectos ??
                            0, // Valor de la cantidad de proyectos
                        pointColorMapper: (DepartamentoViewModel item, _) {
                          // Asignar colores diferentes a cada barra
                          return _getBarColor(item);
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize:
                                  8), // Tamaño de las etiquetas en las barras
                        ),
                      ),
                    ],
                    legend: Legend(
                      isVisible: false, // Ocultar la leyenda
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para asignar diferentes colores a cada barra
  Color _getBarColor(DepartamentoViewModel item) {
    List<Color> colors = [
      Colors.purpleAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.greenAccent,
    ];

    // Asignar colores basados en el hash del nombre del estado
    int index = item.esta_Nombre.hashCode % colors.length;
    return colors[index];
  }
}
