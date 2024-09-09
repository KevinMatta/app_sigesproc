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
  TooltipBehavior _tooltipBehavior =
      TooltipBehavior(enable: true); // Habilitar tooltip

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.ProyectosPorDepartamento();
  }

  // Función para formatear los números
  String formatNumber(int value) {
    return value.toString();
  }

  // Función para calcular el porcentaje
  String calculatePercentage(int value, int total) {
    return ((value / total) * 100).toStringAsFixed(2) + "%";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(8.0),
          color: const Color(0xFF171717),
          child: FutureBuilder<List<DepartamentoViewModel>>(
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
                return _buildVerticalBarChart(snapshot.data!, constraints);
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

  Widget _buildVerticalBarChart(
      List<DepartamentoViewModel> data, BoxConstraints constraints) {
    int totalProyectos =
        data.fold(0, (sum, item) => sum + (item.cantidad_Proyectos ?? 0));

    return Column(
      children: [
        Container(
          height: constraints.maxHeight * 0.70,
          width: constraints.maxWidth * 0.95,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Cantidad de Proyectos por Departamento',
              textStyle: TextStyle(
                color: const Color(0xFFFFF0C6),
                fontSize: 11,
              ),
            ),
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(color: Colors.white, fontSize: 8),
              title: AxisTitle(
                  text: 'Estado',
                  textStyle: TextStyle(color: Colors.white, fontSize: 10)),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: 'Cantidad de Proyectos',
                  textStyle: TextStyle(color: Colors.white, fontSize: 8)),
              labelStyle: TextStyle(color: Colors.white, fontSize: 8),
              majorGridLines: MajorGridLines(
                width: 1, // Asegura que las líneas de fondo sean visibles
                color: Colors.grey
                    .withOpacity(0.5), // Color y opacidad de las líneas
              ),
            ),
            tooltipBehavior: _tooltipBehavior, // Tooltip para mostrar cantidad
            series: <ChartSeries>[
              ColumnSeries<DepartamentoViewModel, String>(
                dataSource: data,
                xValueMapper: (DepartamentoViewModel item, index) =>
                    item.esta_Nombre ?? '',
                yValueMapper: (DepartamentoViewModel item, index) =>
                    item.cantidad_Proyectos ?? 0,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: Colors.white, fontSize: 8),
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    final DepartamentoViewModel item = data;
                    return Text(
                      '${calculatePercentage(item.cantidad_Proyectos ?? 0, totalProyectos)}',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    );
                  },
                ),
                pointColorMapper: (DepartamentoViewModel item, index) {
                  List<Color> barColors = [
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                    Colors.orange,
                  ];
                  return barColors[index % barColors.length];
                },
                enableTooltip: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Wrap(
          children: List<Widget>.generate(data.length, (int index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: _getBarColor(index),
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    data[index].esta_Nombre ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // Función para asignar diferentes colores a cada barra
  Color _getBarColor(int index) {
    List<Color> colors = [
      Colors.blue.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      Colors.red.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
    ];
    return colors[index % colors.length];
  }
}
