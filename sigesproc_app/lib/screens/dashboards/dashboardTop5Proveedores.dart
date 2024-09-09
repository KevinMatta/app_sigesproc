import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopProveedoresDashboard extends StatefulWidget {
  @override
  _TopProveedoresDashboardState createState() =>
      _TopProveedoresDashboardState();
}

class _TopProveedoresDashboardState extends State<TopProveedoresDashboard> {
  late Future<List<ProveedorViewModel>> _dashboardData;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
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
    _dashboardData = DashboardService.listarTop5Proveedores();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Agregamos el scroll
          child: Container(
            color: const Color(0xFF171717),
            padding: EdgeInsets.all(8.0),
            child: FutureBuilder<List<ProveedorViewModel>>(
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
                        "No hay suficientes proveedores para mostrar los 5 más cotizados.");
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
      List<ProveedorViewModel> data, BoxConstraints constraints) {
    // Calcular el total de cotizaciones
    int totalCotizaciones =
        data.fold(0, (sum, item) => sum + (item.numeroDeCotizaciones ?? 0));

    return Column(
      children: [
        Container(
          height: constraints.maxHeight * 0.70,
          width: constraints.maxWidth *
              0.95, // Usamos el mismo ancho que el otro gráfico
          child: SfCircularChart(
            title: ChartTitle(
              text: 'Top 5 Proveedores más Cotizados',
              textStyle: TextStyle(
                  color: const Color(0xFFFFF0C6),
                  fontSize: 10), // Reducir tamaño del título
            ),
            tooltipBehavior:
                _tooltipBehavior, // Habilitar tooltip para mostrar cantidad
            series: <CircularSeries>[
              PieSeries<ProveedorViewModel, String>(
                dataSource: data,
                xValueMapper: (ProveedorViewModel item, index) =>
                    item.provDescripcion ?? '',
                yValueMapper: (ProveedorViewModel item, index) =>
                    _selectedSections[index]
                        ? item.numeroDeCotizaciones ?? 0
                        : 0, // Mostrar solo las secciones seleccionadas
                dataLabelMapper: (ProveedorViewModel item, _) {
                  double percentage =
                      ((item.numeroDeCotizaciones ?? 0) / totalCotizaciones) *
                          100;
                  return '${percentage.toStringAsFixed(2)}%'; // Mostrar porcentaje
                },
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition
                      .outside, // Etiquetas afuera del gráfico
                  textStyle: TextStyle(
                      color: Colors.white, fontSize: 8), // Texto más pequeño
                ),
                pointColorMapper: (ProveedorViewModel item, index) {
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
                radius: '95%',
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
                      size: 12, // Tamaño más pequeño del ícono
                    ),
                    SizedBox(width: 4),
                    Text(
                      data[index].provDescripcion ?? '',
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
