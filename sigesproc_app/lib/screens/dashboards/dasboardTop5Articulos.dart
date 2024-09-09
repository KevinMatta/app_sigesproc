import 'package:flutter/material.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Para manejar el formato de números
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopArticlesDashboard extends StatefulWidget {
  @override
  _TopArticlesDashboardState createState() => _TopArticlesDashboardState();
}

class _TopArticlesDashboardState extends State<TopArticlesDashboard> {
  late Future<List<DashboardArticulosViewModel>> _dashboardData;
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
    _dashboardData = DashboardService.listarTop5ArticulosComprados();
  }

  // Función para formatear los números con puntos y comas
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
          padding: EdgeInsets.all(8.0), // Reducir padding
          child: FutureBuilder<List<DashboardArticulosViewModel>>(
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
      List<DashboardArticulosViewModel> data, BoxConstraints constraints) {
    // Calcular el total de compras
    int totalCompras =
        data.fold(0, (sum, item) => sum + (item.numeroCompras ?? 0));

    return Column(
      children: [
        Container(
          height: constraints.maxHeight *
              0.70, // Reducir la altura del gráfico para evitar desbordamiento
          width: constraints.maxWidth * 0.95,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Top 5 Artículos más Comprados',
              textStyle: TextStyle(
                  color: const Color(0xFFFFF0C6),
                  fontSize: 10), // Reducir tamaño del título
            ),
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 0), // Ocultar etiquetas del eje X
              labelRotation: 0,
              title: AxisTitle(
                  text: '', // Remover título del eje X
                  textStyle: TextStyle(color: Colors.transparent, fontSize: 0)),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: 'Número de Compras',
                  textStyle: TextStyle(color: Colors.white, fontSize: 8)),
              labelStyle: TextStyle(color: Colors.white, fontSize: 8),
            ),
            tooltipBehavior:
                _tooltipBehavior, // Habilitar tooltip para mostrar cantidad
            series: <ChartSeries>[
              ColumnSeries<DashboardArticulosViewModel, String>(
                dataSource: data,
                xValueMapper: (DashboardArticulosViewModel item, index) =>
                    item.articulo ?? '',
                yValueMapper: (DashboardArticulosViewModel item, index) =>
                    _selectedBars[index]
                        ? item.numeroCompras ?? 0
                        : null, // Mostrar solo las barras seleccionadas
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: Colors.white, fontSize: 8),
                  // Mostrar porcentaje en la barra
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    final DashboardArticulosViewModel item = data;
                    return Text(
                      '${calculatePercentage(item.numeroCompras ?? 0, totalCompras)}',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    );
                  },
                ),
                // Colores personalizados para cada barra
                pointColorMapper: (DashboardArticulosViewModel item, index) {
                  List<Color> barColors = [
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                    Colors.orange,
                  ];
                  return barColors[index % barColors.length];
                },
                enableTooltip:
                    true, // Mostrar cantidad en el tooltip cuando se toca la barra
                name:
                    'Artículos', // Añadir el nombre al gráfico para mostrar en la leyenda
              ),
            ],
          ),
        ),
        SizedBox(height: 5), // Espaciado reducido
        // Leyendas con íconos personalizados más pequeños
        Wrap(
          children: List<Widget>.generate(data.length, (int index) {
            return Padding(
              padding:
                  const EdgeInsets.all(4.0), // Reducir padding de las leyendas
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
                          : Colors.grey, // Color de la barra
                      size: 12, // Tamaño reducido del ícono
                    ),
                    SizedBox(width: 2),
                    Text(
                      data[index].articulo ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Tamaño reducido del texto
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

  // Función para obtener el color de la barra según el índice
  Color _getBarColor(int index) {
    List<Color> barColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
    ];
    return barColors[index % barColors.length];
  }
}
