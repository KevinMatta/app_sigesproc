import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart';

class PrestamosViaticosDashboard extends StatefulWidget {
  @override
  _PrestamosViaticosDashboardState createState() =>
      _PrestamosViaticosDashboardState();
}

class _PrestamosViaticosDashboardState
    extends State<PrestamosViaticosDashboard> {
  late Future<List<DashboardViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarPrestamosMesDias();
  }

  String obtenerNombreMes(int mes) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat.MMMM('es');
    final DateTime fecha = DateTime(now.year, mes);
    return formatter.format(fecha).toString();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF171717),
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder<List<DashboardViewModel>>(
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
                // Filtrar solo los datos del mes actual
                final mesActual = DateTime.now().month;
                final dataMesActual = snapshot.data!
                    .where((item) => item.mes == mesActual)
                    .toList();

                return _buildLineChart(dataMesActual, constraints);
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

  Widget _buildLineChart(
      List<DashboardViewModel> data, BoxConstraints constraints) {
    // Aquí agregamos el print para ver lo que trae 'data' filtrado por el mes actual
    data.forEach((item) {
      print(
          'Día: ${item.dia}, Mes: ${item.mes}, Año: ${item.anio}, Total Monto Prestado: ${item.totalMontoPrestado}');
    });
    final mesActual = DateTime.now().month;
    final nombreMesActual = obtenerNombreMes(mesActual);

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          return Container(
            height: screenHeight *
                0.5, // Ajustar la altura en función del tamaño de la pantalla
            width: screenWidth *
                0.95, // Ajustar el ancho en función del tamaño de la pantalla
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, // Ajustar márgenes laterales
              vertical:
                  screenHeight * 0.02, // Ajustar márgenes superior e inferior
            ),
            child: SfCartesianChart(
              margin: EdgeInsets.all(
                  screenWidth * 0.00), // Márgenes alrededor del gráfico
              title: ChartTitle(
                text: 'Prestamos Viáticos - $nombreMesActual',
                textStyle: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: screenWidth < 600
                      ? 11
                      : 16, // Ajustar el tamaño del texto según el ancho
                ),
              ),
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                  fontSize: screenWidth < 600
                      ? 8
                      : 12, // Tamaño de las etiquetas del eje X
                  color: Colors.white,
                ),
                labelIntersectAction: AxisLabelIntersectAction.wrap,
                title: AxisTitle(
                  text: 'Días del Mes',
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth < 600
                        ? 10
                        : 14, // Ajustar el tamaño del texto según el ancho
                  ),
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                labelStyle: TextStyle(
                  fontSize: screenWidth < 600
                      ? 8
                      : 12, // Tamaño de las etiquetas del eje Y
                  color: Colors.white,
                ),
                title: AxisTitle(
                  text: 'Monto Prestado',
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth < 600
                        ? 10
                        : 14, // Ajustar el tamaño del texto según el ancho
                  ),
                ),
                majorGridLines: MajorGridLines(width: 0),
              ),
              tooltipBehavior: _tooltipBehavior,
              series: <ChartSeries>[
                LineSeries<DashboardViewModel, int>(
                  dataSource: data,
                  xValueMapper: (DashboardViewModel item, _) => item.dia ?? 0,
                  yValueMapper: (DashboardViewModel item, _) =>
                      item.totalMontoPrestado ?? 0,
                  markerSettings: MarkerSettings(isVisible: true),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth < 600
                          ? 8
                          : 10, // Ajustar el tamaño de las etiquetas de datos
                    ),
                  ),
                  color: Colors.blueAccent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
