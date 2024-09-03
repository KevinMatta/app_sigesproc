import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<DashboardViewModel>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardService.listarFletesEncabezado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Dashboard de Proveedores',
            style: TextStyle(color: Color(0xFFFFF0C6))),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<DashboardViewModel>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          } else if (snapshot.hasData) {
            return _buildPieChart(snapshot.data!);
          } else {
            return Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }

  Widget _buildPieChart(List<DashboardViewModel> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Color(0xFF171717),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Top 5 Proveedores más Cotizados',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _createPieChartSections(data),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Manejar la interacción con el gráfico si es necesario
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      List<DashboardViewModel> data) {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      DashboardViewModel item = entry.value;
      final isTouched = index == 1;
      final double fontSize = isTouched ? 25.0 : 16.0;
      final double radius = isTouched ? 60.0 : 50.0;
      final color = Colors.primaries[index % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: item.numeroDeCotizaciones!.toDouble(),
        title: '${item.prov_Descripcion} (${item.numeroDeCotizaciones})',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();
  }
}
