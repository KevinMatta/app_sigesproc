import 'package:flutter/material.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart'; // Para la moneda global
import 'package:intl/intl.dart'; // Para formatear números

class ProjectCostDashboardCard extends StatefulWidget {
  @override
  _ProjectCostDashboardCardState createState() =>
      _ProjectCostDashboardCardState();
}

class _ProjectCostDashboardCardState extends State<ProjectCostDashboardCard> {
  late Future<List<DashboardProyectoViewModel>> _projectsData;
  String _abreviaturaMoneda = "L"; // Moneda por defecto

  @override
  void initState() {
    super.initState();
    _projectsData = DashboardService
        .listarTop5ProyectosMayorPresupuesto(); // Llamada al servicio
    _obtenerAbreviaturaMoneda(); // Obtener la abreviatura de la moneda
  }

  // Método para obtener la abreviatura de la moneda global
  Future<void> _obtenerAbreviaturaMoneda() async {
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {});
  }

  // Método para formatear el número con comas y dos decimales
  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
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
        child: FutureBuilder<List<DashboardProyectoViewModel>>(
          future: _projectsData,
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
              // Filtrar el proyecto con el mayor presupuesto
              final DashboardProyectoViewModel maxPresupuestoProyecto =
                  snapshot.data!.reduce((curr, next) =>
                      curr.presupuestoTotal! > next.presupuestoTotal!
                          ? curr
                          : next);
              return _buildContent(maxPresupuestoProyecto, currentMonth);
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

  // Método que construye el contenido basado en el proyecto con el mayor presupuesto
  Widget _buildContent(DashboardProyectoViewModel project, int currentMonth) {
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
                'Presupuesto Mayor - ${getMonthName(currentMonth)}',
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
        // Mostrar el nombre del proyecto y su presupuesto total
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.money, // Ícono de dinero
              color: Colors.lightGreenAccent,
              size: 14, // Tamaño del ícono
            ),
            const SizedBox(width: 5), // Espaciado
            Flexible(
              child: Text(
                'Presupuesto: $_abreviaturaMoneda ${formatNumber(project.presupuestoTotal ?? 0.00)}',
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
        // Mostrar el nombre del proyecto
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center, // Ícono de proyectos
              color: Colors.blueAccent,
              size: 14, // Tamaño del ícono
            ),
            const SizedBox(width: 5), // Espaciado
            Flexible(
              child: Text(
                'Proyecto: ${project.proy_Nombre}',
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
