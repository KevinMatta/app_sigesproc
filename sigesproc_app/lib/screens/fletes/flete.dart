import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'detalleflete.dart';

class Flete extends StatefulWidget {
  @override
  _FleteState createState() => _FleteState();
}

class _FleteState extends State<Flete> {
  int _selectedIndex = 2;
  Future<List<FleteEncabezadoViewModel>>? _fletesFuture;
  TextEditingController _searchController = TextEditingController();
  List<FleteEncabezadoViewModel> _filteredFletes = [];

  @override
  void initState() {
    super.initState();
    _fletesFuture = FleteEncabezadoService.listarFletesEncabezado();
    _searchController.addListener(_filterFletes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFletes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFletes() {
    final query = _searchController.text.toLowerCase();
    if (_fletesFuture != null) {
      _fletesFuture!.then((fletes) {
        setState(() {
          _filteredFletes = fletes.where((flete) {
            final salida = flete.salida?.toLowerCase() ?? '';
            return salida.contains(query);
          }).toList();
        });
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget FleteRegistro(FleteEncabezadoViewModel flete) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          flete.codigo.toString(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFF0C6),
      ),
      title: Text(
        flete.salida ?? 'N/A',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Supervisor: ${flete.supervisorLlegada ?? 'N/A'}',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            flete.flenEstado == true ? Icons.adjust : Icons.adjust,
            color: flete.flenEstado == true ? Colors.red : Colors.green,
          ),
          PopupMenuButton<int>(
            color: Colors.black,
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (int result) {
              if (result == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleFlete(flenId: flete.flenId!),
                  ),
                );
              } else if (result == 1) {
                //  "Ver Verificación"
              } else if (result == 2) {
                  _modalEliminar(context, flete);
              } else if (result == 3) {
                //  "Incidencias"
              } else if (result == 4) {
                // "Verificar"
              } else if (result == 5) {
                // "Editar"
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              if (flete.flenEstado == true) ...[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    'Ver Detalle',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text(
                    'Ver Verificación',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
              ] else ...[
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text(
                    'Incidencias',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 4,
                  child: Text(
                    'Verificar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 5,
                  child: Text(
                    'Editar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    'Ver Detalle',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _modalEliminar(BuildContext context, FleteEncabezadoViewModel flete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Eliminar Flete', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Está seguro de querer eliminar el flete hacia ${flete.destino}?',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF171717),
        actions: [
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Color(0xFFFFF0C6))),
            onPressed: () async {
              try {
                await FleteEncabezadoService.Eliminar(flete.flenId!);
                setState(() {
                  print(_filteredFletes);
                  print(flete);
                  _filteredFletes.remove(flete);
                  print('entra a borrar');
                  print(_filteredFletes.remove(flete));
                  print(_filteredFletes);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Flete eliminado con éxito')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar el registro')),
                );
              }
            },
          ),
          TextButton(
            child: Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
                'Fletes',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 18,
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
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Card(
              color: Color(0xFF171717),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar.....',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.white54),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white54),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<FleteEncabezadoViewModel>>(
                future: _fletesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar los datos',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 80.0),
                      itemCount: _filteredFletes.isEmpty
                          ? snapshot.data!.length
                          : _filteredFletes.length,
                      itemBuilder: (context, index) {
                        return FleteRegistro(_filteredFletes.isEmpty
                            ? snapshot.data![index]
                            : _filteredFletes[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoFlete(),
            ),
          );
        },
        backgroundColor: Color(0xFFFFF0C6),
        child: Icon(Icons.add_circle_outline, color: Colors.black),
      ),
    );
  }
}
