import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class DashboardVentasPorAgente extends StatefulWidget {
  @override
  _DashboardVentasPorAgenteState createState() =>
      _DashboardVentasPorAgenteState();
}

class _DashboardVentasPorAgenteState extends State<DashboardVentasPorAgente> {
  late Future<List<VentasPorAgenteViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior =
      TooltipBehavior(enable: true); // Habilitar tooltip
  List<bool> _selectedSections = [
    true,
    true,
    true,
    true,
    true
  ]; // Control de las secciones activadas/desactivadas

  @override
  void initState() {
    super.initState();
    _dashboardData =
        DashboardService.listarVentasPorAgente(); // Llamada al servicio
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: const Color(0xFF171717),
            padding: EdgeInsets.all(8.0),
            child: FutureBuilder<List<VentasPorAgenteViewModel>>(
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
                    print("No hay suficientes agentes para mostrar.");
                  }
                  return _buildPieChart(snapshot.data!, constraints);
                } else {
                  return Center(
                    child: Text('No hay datos disponibles',
                        style: TextStyle(color: Colors.white)),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(
      List<VentasPorAgenteViewModel> data, BoxConstraints constraints) {
    // Calcular el total de ventas
    int totalVentas =
        data.fold(0, (sum, item) => sum + (item.cantidadVendida ?? 0));

    return Column(
      children: [
        Container(
          height: constraints.maxHeight * 0.7, // Ajustamos el tamaño del gráfico
          width: constraints.maxWidth * 0.95, // Usamos el mismo ancho que en el otro gráfico
          child: SfCircularChart(
            title: ChartTitle(
              text: 'Ventas por Agente',
              textStyle: TextStyle(
                  color: const Color(0xFFFFF0C6),
                  fontSize: constraints.maxWidth * 0.04), // Ajuste dinámico del tamaño del texto
            ),
            tooltipBehavior: _tooltipBehavior,
            series: <CircularSeries>[
              PieSeries<VentasPorAgenteViewModel, String>(
                dataSource: data,
                xValueMapper: (VentasPorAgenteViewModel item, index) =>
                    item.agen_NombreCompleto ?? '',
                yValueMapper: (VentasPorAgenteViewModel item, index) =>
                    _selectedSections[index] ? item.cantidadVendida ?? 0 : 0,
                dataLabelMapper: (VentasPorAgenteViewModel item, _) {
                  double percentage =
                      ((item.cantidadVendida ?? 0) / totalVentas) * 100;
                  return '${percentage.toStringAsFixed(2)}%'; // Mostrar porcentaje
                },
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                      color: Colors.white, fontSize: constraints.maxWidth * 0.025), // Texto ajustado
                ),
                pointColorMapper: (VentasPorAgenteViewModel item, index) {
                  List<Color> barColors = [
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                    Colors.orange,
                  ];
                  return barColors[index % barColors.length];
                },
                explode: true,
                explodeAll: true,
                radius: '90%', // Ajustar el radio para mejor visibilidad
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        // Leyendas con íconos personalizados para ocultar/mostrar secciones
        Wrap(
          alignment: WrapAlignment.center,
          children: List<Widget>.generate(data.length, (int index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSections[index] = !_selectedSections[index];
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pie_chart, // Icono de gráfico de pastel
                      color: _selectedSections[index]
                          ? _getBarColor(index)
                          : Colors.grey,
                      size: constraints.maxWidth * 0.035, // Tamaño dinámico del ícono
                    ),
                    SizedBox(width: 4),
                    Text(
                      data[index].agen_NombreCompleto ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: constraints.maxWidth * 0.04, // Texto ajustado dinámicamente
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
      Colors.blue.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      Colors.red.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
    ];
    return barColors[index % barColors.length];
  }
}
