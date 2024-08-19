import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/proyectos/etapaporproyectoviewmodel.dart';
import '../menu.dart';

class LineaDeTiempo extends StatelessWidget {
  final List<EtapaPorProyectoViewModel> etapas;
  final String proyectoNombre;

  const LineaDeTiempo({Key? key, required this.etapas, required this.proyectoNombre}) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha no disponible';
    return DateFormat('EEEE, dd MMMM yyyy', 'es').format(date);
  }

  String _truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo-sigesproc.png',
              height: 60,
            ),
            SizedBox(width: 5),
            Text(
              'SIGESPROC',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Column(
            children: [
              Text(
                'Proyecto: $proyectoNombre',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Container(
                height: 2.0,
                color: Color(0xFFFFF0C6),
              ),
              SizedBox(height: 5),
              Text(
                'Etapas:',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFF0C6)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      drawer: MenuLateral(
        selectedIndex: 1,
        onItemSelected: (index) {
          // Handle menu item selection
        },
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Stack(
              children: [
                  // Posicionar el círculo al inicio de la línea central
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    top: 0,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF0C6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Línea central
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 18,
                    top: 25, // Debajo del círculo
                    bottom: 25, // Encima de la flecha
                    child: Container(
                      width: 2,
                      color: Color(0xFFFFF0C6),
                    ),
                  ),
                  // Posicionar la flecha al final de la línea central
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 32,
                    bottom: 0,
                    child: Icon(
                      Icons.arrow_downward,
                      color: Color(0xFFFFF0C6),
                      size: 30,
                    ),
                  ),
                // Lista de etapas
                  ListView.builder(
                    itemCount: etapas.length,
                    itemBuilder: (context, index) {
                      final etapa = etapas[index];
                      final bool isLeftAligned = index % 2 == 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Row(
                          mainAxisAlignment: isLeftAligned
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isLeftAligned) Spacer(), // Para empujar el contenido a la derecha
                            Column(
                              crossAxisAlignment: isLeftAligned
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    if (!isLeftAligned)
                                      Icon(
                                        Icons.adjust,
                                        color: etapa.etprEstado == true
                                            ? Colors.red
                                            : Colors.green,
                                        size: 25,
                                      ),
                                    Text(
                                      _truncateWithEllipsis(20, etapa.etapDescripcion ?? 'N/A'),
                                      style: TextStyle(
                                        color: Color(0xFFFFF0C6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isLeftAligned)
                                      Icon(
                                        Icons.adjust,
                                        color: etapa.etprEstado == true
                                            ? Colors.red
                                            : Colors.green,
                                        size: 25,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Text(
                                  _formatDate(etapa.etprFechaInicio),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  _formatDate(etapa.etprFechaFin),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            if (isLeftAligned)
                              SizedBox(width: 5), // Espacio entre el icono y la línea
                            if (!isLeftAligned)
                              SizedBox(width: 5), // Espacio ajustado para el lado derecho
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.arrow_downward,
        activeIcon: Icons.close,
        backgroundColor: Color(0xFF171717),
        foregroundColor: Color(0xFFFFF0C6),
        buttonSize: Size(56.0, 56.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        childrenButtonSize: Size(56.0, 56.0),
        spaceBetweenChildren: 10.0,
        overlayColor: Colors.transparent,
        children: [
          SpeedDialChild(
            child: Icon(Icons.arrow_back),
            backgroundColor: Color(0xFFFFF0C6),
            foregroundColor: Color(0xFF171717),
            shape: CircleBorder(), 

            labelBackgroundColor: Color(0xFFFFF0C6),
            labelStyle: TextStyle(color: Color(0xFF171717)),
            onTap: () {
              Navigator.pop(context); // Acción de regresar
            },
          ),
        ],
      ),
    );
  }
}
