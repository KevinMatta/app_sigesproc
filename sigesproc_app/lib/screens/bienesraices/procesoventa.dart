import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';

class ProcesoVenta extends StatefulWidget {
  @override
  _ProcesoVentaState createState() => _ProcesoVentaState();
}

class _ProcesoVentaState extends State<ProcesoVenta> {
  int _selectedIndex = 4;
  Future<List<ProcesoVentaViewModel>>? _procesosventaFuture;
  Future<List<ProcesoVentaViewModel>>? _buscarFuture;
  TextEditingController _searchController = TextEditingController();
  List<ProcesoVentaViewModel> _filteredProcesosVenta = [];
  List<ProcesoVentaViewModel> _filteredVenta = [];
  bool _mostrarVenta = false;

  @override
  void initState() {
    super.initState();
    _procesosventaFuture = ProcesoVentaService.listarProcesosVenta();
    _searchController.addListener(_filterProcesosVenta);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProcesosVenta);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProcesosVenta() {
    final query = _searchController.text.toLowerCase();
    if (_procesosventaFuture != null) {
      _procesosventaFuture!.then((procesosventa) {
        setState(() {
          _filteredProcesosVenta = procesosventa.where((procesoventa) {
            final salida = procesoventa.descripcion?.toLowerCase() ?? '';
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

  void _verVenta(int btrpId, bool terrenobienraizId, int? bienoterrenoid) {
    setState(() {
      _mostrarVenta = true;
      _buscarFuture = ProcesoVentaService.Buscar(btrpId,terrenobienraizId ? 1 : 0,bienoterrenoid!);
    });
  }

  Widget ProcesoVentaRegistro(ProcesoVentaViewModel procesoventa) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          procesoventa.codigo.toString(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFF0C6),
      ),
      title: Text(
        procesoventa.descripcion ?? 'N/A',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Agente: ${procesoventa.agenDNI ?? 'N/A'} - ${procesoventa.agenNombreCompleto ?? 'N/A'}',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () =>
                _verVenta(procesoventa.btrpId,procesoventa.btrpTerrenoOBienRaizId, procesoventa.btrpBienoterrenoId),
          ),
          Icon(
            procesoventa.btrpIdentificador == true ? Icons.adjust : Icons.adjust,
            color: procesoventa.btrpIdentificador == true ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget VentaRegistro(ProcesoVentaViewModel venta) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          venta.codigo.toString(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFF0C6),
      ),
      title: Text(
        'Cotización ${venta.descripcion}',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Fecha: ${venta.btrpFechaPuestaVenta != null ? venta.btrpFechaPuestaVenta! : 'N/A'}\nTotal: ${venta.btrpPrecioVentaFinal}',
        style: TextStyle(color: Colors.white70),
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
            SizedBox(width: 10),
            Text(
              'SIGESPROC',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Bienes Raíces en Venta',
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
              child: _mostrarVenta 
              ? FutureBuilder<List<ProcesoVentaViewModel>>(
                future: _buscarFuture,
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
                      itemCount: _filteredVenta.isEmpty
                          ? snapshot.data!.length
                          : _filteredVenta.length,
                      itemBuilder: (context, index) {
                        return VentaRegistro(
                            _filteredVenta.isEmpty
                                ? snapshot.data![index]
                                : _filteredVenta[index]);
                      },
                    );
                  }
                },
              )
              : FutureBuilder<List<ProcesoVentaViewModel>>(
                future: _procesosventaFuture,
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
                      itemCount: _filteredProcesosVenta.isEmpty
                          ? snapshot.data!.length
                          : _filteredProcesosVenta.length,
                      itemBuilder: (context, index) {
                        return ProcesoVentaRegistro(
                            _filteredProcesosVenta.isEmpty
                                ? snapshot.data![index]
                                : _filteredProcesosVenta[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
