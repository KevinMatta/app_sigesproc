import 'package:flutter/material.dart';

class IncidenceDashboardCard extends StatelessWidget {
  // Hardcoded data for testing purposes
  final int hardcodedMonth = 9; // September
  final int incidenciasTotales = 25; // Hardcoded incidence total
  final int numeroFletesMensuales = 120; // Hardcoded number of freights

  // Helper function to convert month number to month name (in this case September)
  String getMonthName(int monthNumber) {
    List<String> monthNames = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE'
    ];
    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF171717),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
      ),
      elevation: 4, // Add shadow to the card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the month name in the title with an icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today, // Calendar icon
                  color: Color(0xFFFFE645),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tasa de Incidencias - ${getMonthName(hardcodedMonth)}',
                  style: TextStyle(
                    color: Color(0xFFFFF0C6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            // Display total incidences for the month with an icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning, // Incidence icon
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Incidencias Totales: $incidenciasTotales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                  'Número de Fletes Mensuales: $numeroFletesMensuales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
