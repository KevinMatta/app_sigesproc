import 'package:flutter/material.dart';
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
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Etapas del proyecto: $proyectoNombre',
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
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 18,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Color(0xFFFFF0C6),
                    ),
                  ),
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
                            if (!isLeftAligned)
                              Spacer(), // Para empujar el contenido a la derecha
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
                                            ? Colors.green
                                            : Colors.red,
                                        size: 25, 
                                      ),
                                    if (isLeftAligned)
                                      SizedBox(width: 7),
                                    Text(
                                      etapa.etapDescripcion ?? 'N/A',
                                      style: TextStyle(
                                        color: Color(0xFFFFF0C6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!isLeftAligned)
                                      SizedBox(width: 7),
                                    if (isLeftAligned)
                                      Icon(
                                        Icons.adjust,
                                        color: etapa.etprEstado == true
                                            ? Colors.green
                                            : Colors.red,
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
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFF0C6),
                    minimumSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Regresar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
