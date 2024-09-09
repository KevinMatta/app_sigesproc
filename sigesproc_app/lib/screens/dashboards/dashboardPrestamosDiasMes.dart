import 'package:flutter/material.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Para manejar formato de números y monedas
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class PrestamosViaticosDashboard extends StatefulWidget {
  @override
  _PrestamosViaticosDashboardState createState() =>
      _PrestamosViaticosDashboardState();
}

class _PrestamosViaticosDashboardState
    extends State<PrestamosViaticosDashboard> {
  late Future<List<DashboardPrestamoDiasMesViewModel>> _dashboardData;
  String _abreviaturaMoneda = "L"; // Valor predeterminado de moneda
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Función asincrónica para cargar los datos
  Future<void> _loadData() async {
    _dashboardData = DashboardService.listarPrestamosMesDias();
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(
        () {}); // Refresca el widget para reflejar la abreviatura de moneda
  }

  // Función para formatear los números con comas y punto decimal
  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
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
          padding: EdgeInsets
              .zero, // Eliminar padding para que quede al raz del contenedor
          child: FutureBuilder<List<DashboardPrestamoDiasMesViewModel>>(
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

  Widget _buildLineChart(List<DashboardPrestamoDiasMesViewModel> data,
      BoxConstraints constraints) {
    final nombreMesActual = obtenerNombreMes(DateTime.now().month);

    return Container(
      height: constraints.maxHeight, // Ocupa todo el alto del contenedor
      width: constraints.maxWidth, // Ocupa todo el ancho del contenedor
      child: SfCartesianChart(
        margin: EdgeInsets
            .zero, // Eliminar márgenes para que ocupe todo el contenedor
        title: ChartTitle(
          text: 'Total Prestamos - $nombreMesActual',
          textStyle: TextStyle(
            color: Color(0xFFFFF0C6),
            fontSize: MediaQuery.of(context).size.width < 600
                ? 12
                : 18, // Ajustar tamaño de texto
          ),
        ),
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 14,
            color: Colors.white,
          ),
          labelIntersectAction: AxisLabelIntersectAction.wrap,
          title: AxisTitle(
            text: 'Días del Mes',
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 16,
            ),
          ),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          labelStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 14,
            color: Colors.white,
          ),
          title: AxisTitle(
            text: 'Monto Prestado ($_abreviaturaMoneda)',
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 16,
            ),
          ),
          majorGridLines: MajorGridLines(width: 0),
        ),
        tooltipBehavior: _tooltipBehavior,
        series: <ChartSeries>[
          LineSeries<DashboardPrestamoDiasMesViewModel, int>(
            dataSource: data,
            xValueMapper: (DashboardPrestamoDiasMesViewModel item, _) =>
                item.dia ?? 0,
            yValueMapper: (DashboardPrestamoDiasMesViewModel item, _) =>
                item.totalMontoPrestado ?? 0,
            markerSettings: MarkerSettings(isVisible: true),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12,
              ),
              labelAlignment: ChartDataLabelAlignment.bottom,
              offset: Offset(0, 10), // Desplazar etiquetas
            ),
            dataLabelMapper: (DashboardPrestamoDiasMesViewModel item, _) {
              return '$_abreviaturaMoneda ${formatNumber(item.totalMontoPrestado ?? 0.0)}';
            },
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
