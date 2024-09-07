import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class TopWarehousesDashboard extends StatefulWidget {
  @override
  _TopWarehousesDashboardState createState() => _TopWarehousesDashboardState();
}

class _TopWarehousesDashboardState extends State<TopWarehousesDashboard> {
  late Future<List<TopNumeroDestinosFletesViewModel>> _dashboardData;

  @override
  void initState() {
    super.initState();
    // Fetching the dynamic data for the top 5 frequent warehouses
    _dashboardData = DashboardService.listarTop5BodegasDestino();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171717),
      child: FutureBuilder<List<TopNumeroDestinosFletesViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFFFE645)));
          } else if (snapshot.hasError) {
            // Debugging the error message
            print('Error: ${snapshot.error}');
            return Center(
                child: Text('Error al cargar los datos',
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          } else if (snapshot.hasData) {
            // Log the data in console
            print('Data fetched: ${snapshot.data}');

            // Log individual elements for better visibility
            snapshot.data!.forEach((item) {
              print(
                  'destino: ${item.destino}, Numero de Fletes: ${item.numeroFletes}');
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

  Widget _buildVerticalBarChart(List<TopNumeroDestinosFletesViewModel> data) {
    return SingleChildScrollView(
      // This allows scrolling to avoid overflow issues
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Reduced padding
        child: Card(
          color: const Color(0xFF171717),
          child: Padding(
            padding:
                const EdgeInsets.all(4.0), // Reduced padding inside the card
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Top 5 Bodegas más Frecuentes',
                  style: TextStyle(
                    color: const Color(0xFFFFF0C6),
                    fontSize: 10, // Decreased font size for the title
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4.0), // Reduced spacing
                Container(
                  height: 140, // Adjust chart height as needed
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 6), // Reduced text size for Bodega names
                      title: AxisTitle(
                        text: 'Bodega (Destino)',
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 8), // Reduced axis title size
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 8), // Reduced text size for axis labels
                      title: AxisTitle(
                        text: 'Número de Fletes',
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 8), // Reduced axis title size
                      ),
                    ),
                    series: <ChartSeries>[
                      ColumnSeries<TopNumeroDestinosFletesViewModel, String>(
                        name: 'Número de Fletes',
                        dataSource: data,
                        xValueMapper: (TopNumeroDestinosFletesViewModel item, _) =>
                            item.destino ?? '',
                        yValueMapper: (TopNumeroDestinosFletesViewModel item, _) =>
                            item.numeroFletes ?? 0,
                        pointColorMapper: (TopNumeroDestinosFletesViewModel item, _) {
                          // Assign different colors to each bar
                          return _getBarColor(item);
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 8), // Reduced data label size
                        ),
                      ),
                    ],
                    // Removed legend and second bar series
                    legend: Legend(
                      isVisible: false, // No legend needed
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

// Function to assign different colors to each bar
  Color _getBarColor(TopNumeroDestinosFletesViewModel item) {
    List<Color> colors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];

    // Example: Map each item to a color based on its position in the list
    int index = item.destino.hashCode % colors.length;
    return colors[index];
  }
}
