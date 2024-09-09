import 'package:flutter/material.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:intl/intl.dart'; // Para formatear números
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart'; // Para la moneda global

class IncidenceCostDashboardCard extends StatefulWidget {
  @override
  _IncidenceCostDashboardCardState createState() =>
      _IncidenceCostDashboardCardState();
}

class _IncidenceCostDashboardCardState
    extends State<IncidenceCostDashboardCard> {
  late Future<List<IncidenciasMensulaesProyectoViewmodel>> _incidenciasData;
  String _abreviaturaMoneda = "L"; // Moneda por defecto

  @override
  void initState() {
    super.initState();
    _incidenciasData =
        DashboardService.proyectosTotalIncidenciasMes(); // Llamada al servicio
    _obtenerAbreviaturaMoneda(); // Obtener la abreviatura de la moneda
  }

  // Método para obtener la abreviatura de la moneda global
  Future<void> _obtenerAbreviaturaMoneda() async {
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {});
  }

  // Helper function para convertir el número del mes al nombre del mes actual
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
    return monthNames[monthNumber - 1]; // Ajuste por lista indexada en 0
  }

// Método para formatear el número sin punto para miles y con punto para decimales
  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00',
        'en_US'); // En_US usa la coma como separador de miles y el punto para decimales
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    int currentMonth = DateTime.now().month; // Obtener el mes actual

    return Card(
      color: Color(0xFF171717),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Esquinas redondeadas
      ),
      elevation: 3, // Elevación de la sombra
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Espaciado interno
        child: FutureBuilder<List<IncidenciasMensulaesProyectoViewmodel>>(
          future: _incidenciasData,
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
              final IncidenciasMensulaesProyectoViewmodel data =
                  snapshot.data!.first; // Usamos el primer dato
              return _buildContent(data, currentMonth);
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
  Widget _buildContent(
      IncidenciasMensulaesProyectoViewmodel data, int currentMonth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mes actual
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today, // Ícono de calendario
              color: Color(0xFFFFE645),
              size: 16, // Tamaño del ícono
            ),
            const SizedBox(width: 5), // Espaciado
            Flexible(
              child: Text(
                'Incidencias - ${getMonthName(currentMonth)}',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 9, // Tamaño del texto
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Elipsis si el texto es largo
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // Espaciado vertical
        // Mostrar el costo total de incidencias
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money, // Ícono de dinero
              color: Colors.greenAccent,
              size: 14, // Tamaño del ícono
            ),
            const SizedBox(width: 5), // Espaciado
            Flexible(
              child: Text(
                'Costo: $_abreviaturaMoneda ${formatNumber(data.totalCostoIncidencias ?? 0.00)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Tamaño del texto
                ),
                overflow: TextOverflow.ellipsis, // Elipsis si el texto es largo
              ),
            ),
          ],
        ),
        const SizedBox(height: 5), // Espaciado vertical
        // Mostrar el total de incidencias del mes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded, // Ícono de advertencia
              color: Colors.redAccent,
              size: 14, // Tamaño del ícono
            ),
            const SizedBox(width: 5), // Espaciado
            Flexible(
              child: Text(
                'Incidencias: ${data.totalIncidencias ?? 0}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Tamaño del texto
                ),
                overflow: TextOverflow.ellipsis, // Elipsis si el texto es largo
              ),
            ),
          ],
        ),
      ],
    );
  }
}
