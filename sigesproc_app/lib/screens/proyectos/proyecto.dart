import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';

class Proyecto extends StatefulWidget {
  @override
  _ProyectoState createState() => _ProyectoState();
}

class _ProyectoState extends State<Proyecto> {
   int _selectedIndex = 1;
   Future<List<ProyectoViewModel>>? _proyectosFuture;
  TextEditingController _searchController = TextEditingController();
  List<ProyectoViewModel> _proyectosFiltrados = [];

   @override
  void initState() {
    super.initState();
    _proyectosFuture = ProyectoService.listarProyectos();
    _searchController.addListener(_proyectoFiltrado);
  }

  @override
  void dispose() {
    _searchController.removeListener(_proyectoFiltrado);
    _searchController.dispose();
    super.dispose();
  }

  void _proyectoFiltrado() {
    final query = _searchController.text.toLowerCase();
    if (_proyectosFuture != null) {
      _proyectosFuture!.then((proyectos) {
        setState(() {
          _proyectosFiltrados = proyectos.where((proyecto) {
            final salida = proyecto.proyNombre?.toLowerCase() ?? '';
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

  Widget ProyectoRegistro(ProyectoViewModel proyecto, int index) {
  return ListTile(
    leading: CircleAvatar(
      child: Text(
        (index + 1).toString(),  // Aquí se usa el índice + 1 para mostrar el número secuencial
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Color(0xFFFFF0C6),
    ),
    title: Text(
      proyecto.proyNombre ?? 'N/A',
      style: TextStyle(color: Colors.white),
    ),
    subtitle: Text(
      'Supervisor: ${proyecto.proyDescripcion ?? 'N/A'}',
      style: TextStyle(color: Colors.white70),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          proyecto.proyEstado == true ? Icons.adjust : Icons.adjust,
          color: proyecto.proyEstado == true ? Colors.red : Colors.green,
        ),
        PopupMenuButton<int>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onSelected: (int result) {
            if (result == 0) {
              // Acción 1
            } else if (result == 1) {
              // Acción 2
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(
              value: 0,
              child: Text('Acción 1'),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text('Acción 2'),
            ),
          ],
        ),
      ],
    ),
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
                'Proyectos',
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
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<ProyectoViewModel>>(
                future: _proyectosFuture,
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
                      itemCount: _proyectosFiltrados.isEmpty ? snapshot.data!.length : _proyectosFiltrados.length,
                      itemBuilder: (context, index) {
                        return ProyectoRegistro(_proyectosFiltrados.isEmpty ? snapshot.data![index] : _proyectosFiltrados[index], index);
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