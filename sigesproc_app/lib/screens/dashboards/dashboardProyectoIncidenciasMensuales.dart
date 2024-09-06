import 'package:flutter/material.dart';

class IncidenceCostDashboardCard extends StatelessWidget {
  // Hardcoded data for testing purposes
  final int hardcodedMonth = 9; // September
  final int costoIncidencia = 1333; // Hardcoded cost of incidence
  final int incidenciasMensuales = 6; // Hardcoded monthly incidence count

  // Helper function to convert month number to month name (in this case September)
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
    return monthNames[monthNumber - 1]; // Adjust for 0-indexed list
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF171717),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Smaller rounded corners
      ),
      elevation: 3, // Reduced shadow elevation
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
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
                  size: 16, // Smaller icon size
                ),
                const SizedBox(width: 5), // Reduced spacing
                Flexible(
                  // Wrap Text in Flexible
                  child: Text(
                    'Incidencias - ${getMonthName(hardcodedMonth)}',
                    style: TextStyle(
                      color: Color(0xFFFFF0C6),
                      fontSize: 9, // Smaller text
                      fontWeight: FontWeight.bold,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis to long text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Reduced vertical spacing
            // Display cost of incidences for the month with an icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_money, // Money icon
                  color: Colors.greenAccent,
                  size: 14, // Smaller icon size
                ),
                const SizedBox(width: 5), // Reduced spacing
                Flexible(
                  // Wrap Text in Flexible
                  child: Text(
                    'Costo: \LPS ${costoIncidencia}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Smaller text
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis to long text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Reduced vertical spacing
            // Display total incidences for the month with an icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded, // Warning icon
                  color: Colors.redAccent,
                  size: 14, // Smaller icon size
                ),
                const SizedBox(width: 5), // Reduced spacing
                Flexible(
                  // Wrap Text in Flexible
                  child: Text(
                    'Incidencias: $incidenciasMensuales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Smaller text
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis to long text
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
