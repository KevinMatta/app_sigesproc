import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para formatear números

class TopWarehousesDashboard extends StatefulWidget {
  @override
  _TopWarehousesDashboardState createState() => _TopWarehousesDashboardState();
}

class _TopWarehousesDashboardState extends State<TopWarehousesDashboard> {
  late Future<List<TopNumeroDestinosFletesViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior =
      TooltipBehavior(enable: true); // Habilitar tooltip
  List<bool> _selectedBars = [
    true,
    true,
    true,
    true,
    true
  ]; // Control de las barras activadas/desactivadas

  @override
  void initState() {
    super.initState();
    // Fetching the dynamic data for the top 5 frequent warehouses
    _dashboardData = DashboardService.listarTop5BodegasDestino();
  }

  // Función para formatear los números con comas
  String formatNumber(int value) {
    final NumberFormat formatter = NumberFormat('#,##0', 'es_ES');
    return formatter.format(value);
  }

  // Función para calcular porcentaje
  String calculatePercentage(int value, int total) {
    return ((value / total) * 100).toStringAsFixed(2) + "%";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF171717),
          child: FutureBuilder<List<TopNumeroDestinosFletesViewModel>>(
            future: _dashboardData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFE645)),
                );
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(
                  child: Text('Error al cargar los datos',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                );
              } else if (snapshot.hasData) {
                return _buildVerticalBarChart(snapshot.data!,
                    constraints); // Aquí pasamos las restricciones
              } else {
                return Center(
                  child: Text('No hay datos disponibles',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildVerticalBarChart(
      List<TopNumeroDestinosFletesViewModel> data, BoxConstraints constraints) {
    int totalFletes =
        data.fold(0, (sum, item) => sum + (item.numeroFletes ?? 0));

    return Column(
      children: [
        Container(
          height: constraints.maxHeight * 0.70, // Ajustar altura
          width: constraints.maxWidth * 0.95, // Ajustar ancho
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Top 5 Bodegas más Frecuentes',
              textStyle:
                  TextStyle(color: const Color(0xFFFFF0C6), fontSize: 10),
            ),
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 0), // Ocultar etiquetas del eje X
              labelRotation: 0,
              title: AxisTitle(
                  text: '',
                  textStyle: TextStyle(color: Colors.transparent, fontSize: 0)),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: 'Número de Fletes',
                  textStyle: TextStyle(color: Colors.white, fontSize: 8)),
              labelStyle: TextStyle(color: Colors.white, fontSize: 8),
            ),
            tooltipBehavior: _tooltipBehavior,
            series: <ChartSeries>[
              ColumnSeries<TopNumeroDestinosFletesViewModel, String>(
                dataSource: data,
                xValueMapper: (TopNumeroDestinosFletesViewModel item, index) =>
                    item.destino ?? '',
                yValueMapper: (TopNumeroDestinosFletesViewModel item, index) =>
                    _selectedBars[index] ? item.numeroFletes ?? 0 : null,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: Colors.white, fontSize: 8),
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    final TopNumeroDestinosFletesViewModel item = data;
                    return Text(
                      '${calculatePercentage(item.numeroFletes ?? 0, totalFletes)}',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    );
                  },
                ),
                pointColorMapper:
                    (TopNumeroDestinosFletesViewModel item, index) {
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
                name: 'Fletes',
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Wrap(
          children: List<Widget>.generate(data.length, (int index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedBars[index] = !_selectedBars[index];
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: _selectedBars[index]
                          ? _getBarColor(index)
                          : Colors.grey,
                      size: 12,
                    ),
                    SizedBox(width: 2),
                    Text(
                      data[index].destino ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Color _getBarColor(int index) {
    List<Color> barColors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];
    return barColors[index % barColors.length];
  }
}
