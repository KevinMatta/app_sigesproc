import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';
import 'package:intl/intl.dart'; // Para manejar formato de números y monedas

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
    _abreviaturaMoneda = (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {}); // Refresca el widget para reflejar la abreviatura de moneda
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
          padding: EdgeInsets.all(16.0),
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










Widget _buildLineChart(List<DashboardPrestamoDiasMesViewModel> data, BoxConstraints constraints) {
  // Mostrar datos filtrados
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
          height: screenHeight * 0.6, // Ajustar la altura en función de la pantalla
          width: screenWidth * 0.95, // Ajustar el ancho en función de la pantalla
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, // Añadir más margen lateral
            vertical: screenHeight * 0.04, // Añadir más margen superior e inferior
          ),
          child: SfCartesianChart(
            margin: EdgeInsets.only(
              top: screenHeight * 0.02, // Espacio superior entre el gráfico y el borde
              bottom: screenHeight * 0.05, // Espacio entre el gráfico y las etiquetas
              left: screenWidth * 0.02,
              right: screenWidth * 0.02,
            ),
            title: ChartTitle(
              text: 'Total Prestamos - $nombreMesActual',
              textStyle: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: screenWidth < 600 ? 12 : 18, // Ajustar el tamaño del texto según el ancho
              ),
            ),
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(
                fontSize: screenWidth < 600 ? 10 : 14, // Tamaño de las etiquetas del eje X
                color: Colors.white,
              ),
              labelIntersectAction: AxisLabelIntersectAction.wrap,
              title: AxisTitle(
                text: 'Días del Mes',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 600 ? 12 : 16, // Ajustar el tamaño del texto según el ancho
                ),
              ),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              labelStyle: TextStyle(
                fontSize: screenWidth < 600 ? 10 : 14, // Tamaño de las etiquetas del eje Y
                color: Colors.white,
              ),
              title: AxisTitle(
                text: 'Monto Prestado ($_abreviaturaMoneda)', // Mostrar abreviatura de la moneda
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 600 ? 12 : 16, // Ajustar el tamaño del texto según el ancho
                ),
              ),
              majorGridLines: MajorGridLines(width: 0),
            ),
            tooltipBehavior: _tooltipBehavior,
            series: <ChartSeries>[
              LineSeries<DashboardPrestamoDiasMesViewModel, int>(
                dataSource: data,
                xValueMapper: (DashboardPrestamoDiasMesViewModel item, _) => item.dia ?? 0,
                yValueMapper: (DashboardPrestamoDiasMesViewModel item, _) =>
                    item.totalMontoPrestado ?? 0,
                markerSettings: MarkerSettings(isVisible: true),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth < 600 ? 10 : 12, // Ajustar el tamaño de las etiquetas de datos
                  ),
                  // Añadir más espacio entre las etiquetas y las líneas
                  labelAlignment: ChartDataLabelAlignment.bottom,
                  offset: Offset(0, 10), // Desplazar hacia abajo las etiquetas
                ),
                dataLabelMapper: (DashboardPrestamoDiasMesViewModel item, _) {
                  return '$_abreviaturaMoneda ${formatNumber(item.totalMontoPrestado ?? 0.0)}';
                },
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
