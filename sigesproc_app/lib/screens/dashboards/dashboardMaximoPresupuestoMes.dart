import 'package:flutter/material.dart';

class ProjectCostDashboardCard extends StatelessWidget {
  // Hardcoded data for testing purposes
  final int hardcodedMonth = 9; // September
  final int totalGastado = 45320; // Hardcoded total spent
  final int proyectosMensuales = 12; // Hardcoded monthly project count

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
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      elevation: 3, // Shadow elevation
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
                  size: 16, // Icon size
                ),
                const SizedBox(width: 5), // Reduced spacing
                Flexible(
                  child: Text(
                    'Presupuesto Mayor - ${getMonthName(hardcodedMonth)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9, // Smaller text
                      fontWeight: FontWeight.bold,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis for long text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Reduced vertical spacing
            // Display total spent with an icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.money, // Money icon
                  color: Colors.lightGreenAccent,
                  size: 14, // Icon size
                ),
                const SizedBox(width: 5), // Reduced spacing
                Flexible(
                  child: Text(
                    'Total Gastado: \$${totalGastado}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Smaller text
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis for long text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Reduced vertical spacing
            // Display total number of projects with an icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_center, // Projects icon
                  color: Colors.blueAccent,
                  size: 14, // Icon size
                ),
                const SizedBox(width: 5), // Reduced spacing
                Flexible(
                  child: Text(
                    'Proyectos Mensuales: $proyectosMensuales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Smaller text
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis for long text
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
