import 'package:flutter/material.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para formatear números
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart'; // Para la moneda global

class IncidenceDashboardCard extends StatefulWidget {
  @override
  _IncidenceDashboardCardState createState() => _IncidenceDashboardCardState();
}

class _IncidenceDashboardCardState extends State<IncidenceDashboardCard> {
  late Future<List<DashboardViewModel>> _dashboardData; // Datos de incidencias
  String _abreviaturaMoneda = "L"; // Moneda por defecto
  int currentMonth = DateTime.now().month; // Mes actual

  @override
  void initState() {
    super.initState();
    _dashboardData =
        DashboardService.listarFletesTasaIncidencias(); // Llamada al servicio
    _obtenerAbreviaturaMoneda(); // Obtener la abreviatura de la moneda
  }

  // Método para obtener la abreviatura de la moneda global
  Future<void> _obtenerAbreviaturaMoneda() async {
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {});
  }

  // Helper function para convertir el número del mes al nombre
  String getMonthName(int monthNumber) {
    List<String> monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF171717),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              // Filtramos los datos para el mes actual
              final filteredData = snapshot.data!
                  .where((data) => data.mes == currentMonth)
                  .toList();

              if (filteredData.isNotEmpty) {
                final DashboardViewModel data =
                    filteredData.first; // Usamos el primer dato filtrado
                return _buildContent(data);
              } else {
                return Center(
                  child: Text('No hay datos disponibles para este mes',
                      style: TextStyle(color: Colors.white)),
                );
              }
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
  }

  // Método que construye el contenido basado en los datos reales
  Widget _buildContent(DashboardViewModel data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mes actual
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              color: Color(0xFFFFE645),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Tasa de Incidencias - ${getMonthName(DateTime.now().month)}',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        // Incidencias Totales
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Incidencias Totales: ${data.incidenciasTotales ?? 0}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Número de Fletes Mensuales
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              color: Colors.greenAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Número de Fletes Mensuales: ${data.numeroFletesMensuales ?? 0}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
