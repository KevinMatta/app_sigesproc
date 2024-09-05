// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
// import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   late Future<List<DashboardViewModel>> _dashboardData;

//   @override
//   void initState() {
//     super.initState();
//     _dashboardData = DashboardService.listarTop5Proveedores();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Keep the original background color
//       body: FutureBuilder<List<DashboardViewModel>>(
//         future: _dashboardData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator(color: Color(0xFFFFE645)));
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error al cargar los datos', style: TextStyle(color: Colors.white)));
//           } else if (snapshot.hasData) {
//             return _buildPieChartContainer(snapshot.data!);
//           } else {
//             return Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)));
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildPieChartContainer(List<DashboardViewModel> data) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         color: Color(0xFF171717), // Keep the original card color
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center, // Center align the title
//             children: [
//               Text(
//                 'Top 5 Proveedores más Cotizados',
//                 style: TextStyle(
//                   color: Color(0xFFFFF0C6), // Light cream color for the title
//                   fontSize: 17, // Title font size
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16.0), // Space between title and pie chart
//               Expanded(
//                 child: PieChart(
//                   PieChartData(
//                     sections: _createPieChartSections(data),
//                     sectionsSpace: 2,
//                     centerSpaceRadius: 0, // Full pie chart (pastel)
//                     borderData: FlBorderData(show: false),
//                     pieTouchData: PieTouchData(
//                       touchCallback: (PieTouchResponse? pieTouchResponse) {
//                         // Handle interaction with the chart if needed
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }











//   List<PieChartSectionData> _createPieChartSections(
//       List<DashboardViewModel> data) {
//     final colors = [
//       Color.fromARGB(255, 50, 74, 100), // Light cream
//      Color.fromARGB(255, 41, 60, 80), // Yellow
//       Color.fromARGB(255, 36, 55, 75), // Dark blue
//       Color.fromARGB(255, 31, 49, 68), // Dark blue

//       Color(0xFF162433), // Dark blue


//       //      Color(0xFFFFE645), // Yellow
//       // Color(0xFFFFF0C6), // Light cream
//       // Color(0xFF162433), // Dark blue
//     ];

//     return data.asMap().entries.map((entry) {
//       int index = entry.key;
//       DashboardViewModel item = entry.value;
//       final double fontSize = 9.0; // Smaller and consistent font size
//       final double radius = 90.0; // Increase the size of the pie chart

//       return PieChartSectionData(
//         color: colors[index % colors.length], // Use specified colors
//         value: item.numeroDeCotizaciones!.toDouble(),
//         title: '${item.prov_Descripcion} (${item.numeroDeCotizaciones})',
//         radius: radius,
//         titleStyle: TextStyle(
//           fontSize: fontSize,
//           fontWeight: FontWeight.bold,
//           color: const Color(0xffffffff),
//         ),
//       );
//     }).toList();
//   }
// }












// Widget _buildCotizacionesTab() {
//   return Container(
//     color: Colors.black, // Keep the container color unchanged
//     padding: const EdgeInsets.all(16.0),
//     child: DashboardScreen(), // Display the larger dashboard with title
//   );
// }
