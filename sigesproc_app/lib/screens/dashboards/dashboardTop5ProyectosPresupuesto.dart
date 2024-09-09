import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para manejar formato de números y monedas
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';

class TopProjectsBudgetDashboard extends StatefulWidget {
  @override
  _TopProjectsBudgetDashboardState createState() =>
      _TopProjectsBudgetDashboardState();
}

class _TopProjectsBudgetDashboardState
    extends State<TopProjectsBudgetDashboard> {
  late Future<List<DashboardProyectoViewModel>> _dashboardData;
  String _abreviaturaMoneda = "L"; // Valor predeterminado de moneda
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true); // Tooltip
  List<bool> _selectedBars = [true, true, true, true, true]; // Filtro de items

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Función asincrónica para cargar la abreviatura de moneda
  Future<void> _loadData() async {
    _dashboardData = DashboardService.listarTop5ProyectosMayorPresupuesto();
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {});
  }

  // Función para formatear los números con comas y punto decimal
  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  // Función para calcular porcentaje
  String calculatePercentage(double value, double total) {
    return ((value / total) * 100).toStringAsFixed(2) + "%";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171717),
      child: FutureBuilder<List<DashboardProyectoViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar los datos',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          } else if (snapshot.hasData) {
            return _buildComparisonBarChartContainer(snapshot.data!);
          } else {
            return Center(
                child: Text('No hay datos disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          }
        },
      ),
    );
  }

  Widget _buildComparisonBarChartContainer(
      List<DashboardProyectoViewModel> data) {
    // Calcular el presupuesto total de todos los proyectos
    double totalPresupuesto =
        data.fold(0.0, (sum, item) => sum + (item.presupuestoTotal ?? 0.0));

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
                  'Top 5 Proyectos con Mayor Presupuesto',
                  style: TextStyle(
                    color: const Color(0xFFFFF0C6),
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0), // Reduced spacing
                Container(
                  width: double.infinity,
                  height: 200, // Ajustar altura
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 8), // Smaller text
                      title: AxisTitle(
                        text: 'Proyecto',
                        textStyle: const TextStyle(
                            color: Colors.white, fontSize: 8), // Smaller text
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 8), // Smaller text
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '', // Eliminar el encabezado del tooltip
                      format:
                          'point.x : point.y', // Formato para mostrar el tooltip
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        final DashboardProyectoViewModel item = data;
                        return Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$_abreviaturaMoneda ${formatNumber(item.presupuestoTotal ?? 0.0)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                    // Habilitar tooltip
                    series: <ChartSeries>[
                      BarSeries<DashboardProyectoViewModel, String>(
                        name: 'Presupuesto',
                        dataSource: data,
                        xValueMapper: (DashboardProyectoViewModel item, _) =>
                            item.proy_Nombre ?? '',
                        yValueMapper: (DashboardProyectoViewModel item, index) {
                          return _selectedBars[index]
                              ? item.presupuestoTotal ?? 0.0
                              : null;
                        },
                        pointColorMapper:
                            (DashboardProyectoViewModel item, index) {
                          // Asignar diferentes colores a cada barra
                          List<Color> barColors = [
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.purple,
                            Colors.orange,
                          ];
                          return barColors[index % barColors.length];
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle:
                              const TextStyle(color: Colors.white, fontSize: 8),
                          labelAlignment: ChartDataLabelAlignment.middle,
                        ),
                        dataLabelMapper: (DashboardProyectoViewModel item, _) {
                          // Mostrar el porcentaje sobre la barra
                          final double presupuesto =
                              item.presupuestoTotal ?? 0.0;
                          return calculatePercentage(
                              presupuesto, totalPresupuesto);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // Spacing for filtering options
                _buildFilteringOptions(data), // Llamada al widget de filtrado
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para mostrar las opciones de filtrado (aparecer/desaparecer barras)
  Widget _buildFilteringOptions(List<DashboardProyectoViewModel> data) {
    return Wrap(
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
                      : Colors.grey, // Color de la barra
                  size: 12, // Tamaño reducido del ícono
                ),
                SizedBox(width: 2),
                Text(
                  data[index].proy_Nombre ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10, // Tamaño reducido del texto
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
