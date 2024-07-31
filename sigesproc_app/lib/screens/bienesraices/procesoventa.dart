import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProcesoVenta extends StatefulWidget {
  @override
  _ProcesoVentaState createState() => _ProcesoVentaState();
}

class _ProcesoVentaState extends State<ProcesoVenta> {
  int _selectedIndex = 4;
  Future<List<ProcesoVentaViewModel>>? _procesosventaFuture;
  TextEditingController _searchController = TextEditingController();
  List<ProcesoVentaViewModel> _filteredProcesosVenta = [];
  List<ProcesoVentaViewModel>? _selectedVenta;

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

  void _verDetalles(int btrpId, bool terrenobienraizId, int? bienoterrenoid) {
    setState(() {
      _procesosventaFuture = ProcesoVentaService.Buscar(btrpId, terrenobienraizId ? 1 : 0, bienoterrenoid!);
      _procesosventaFuture!.then((value) {
        setState(() {
          _selectedVenta = value;
          print('Detalles venta: $_selectedVenta');
        });
      }).catchError((error) {
        print('Error: $error');
      });
    });
  }

  void _launchURL(String url) async {
    print(' URL: $url');
    if (await canLaunch(url)) {
      await launch(url);
      print('URL launch: $url');
    } else {
      print('error URL: $url');
      throw 'No se pudo abrir el enlace $url';
    }
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
            onPressed: () => _verDetalles(procesoventa.btrpId, procesoventa.btrpTerrenoOBienRaizId, procesoventa.btrpBienoterrenoId),
          ),
          Icon(
            procesoventa.btrpIdentificador == true ? Icons.adjust : Icons.adjust,
            color: procesoventa.btrpIdentificador == true ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget VentaDetalles(List<ProcesoVentaViewModel> ventas) {
    ProcesoVentaViewModel venta = ventas.first;
    List<String> imagenes = ventas.map((e) => e.imprImagen!).toList();
    print('Imagenes: $imagenes');

    return Column(
      children: [
        if (imagenes.isNotEmpty) ...[
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: imagenes.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.network(
                    'https://localhost:44337$imagePath',
                    headers: {'XApiKey': '4b567cb1c6b24b51ab55248f8e66e5cc'},
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  );
                },
              );
            }).toList(),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      venta.descripcion ?? 'N/A',
                      style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 22),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Icon(
                    venta.btrpIdentificador == true ? Icons.adjust : Icons.adjust,
                    color: venta.btrpIdentificador == true ? Colors.green : Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              InkWell(
                onTap: () => _launchURL(venta.linkUbicacion ?? ''),
                child: Text(
                  'Ver ubicación',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: 8.0),
              Divider(color: Colors.white70), // Línea de separación
              SizedBox(height: 8.0),
              Text(
                venta.agenNombreCompleto ?? 'N/A',
                style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.white70),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'DNI: ${venta.agenDNI ?? 'N/A'}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Icon(Icons.phone, color: Colors.white70),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Teléfono: ${venta.agenTelefono ?? 'N/A'}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF0C6),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor Inicial: L. ${venta.btrpPrecioVentaInicio?.toStringAsFixed(2) ?? 'N/A'}',
                          style: TextStyle(color: Colors.black),
                        ),
                        if (venta.btrpIdentificador == false)
                          Text(
                            'Vendido por: L. ${venta.btrpPrecioVentaFinal?.toStringAsFixed(2) ?? 'N/A'}\nFecha Vendida: ${venta.btrpFechaVendida != null ? venta.btrpFechaVendida! : 'N/A'}',
                            style: TextStyle(color: Colors.black),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: venta.btrpIdentificador == false ? Colors.black : Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        venta.btrpIdentificador == false ? 'Vendido' : 'En Venta',
                        style: TextStyle(color: Color(0xFFFFF0C6)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedVenta = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Text(
              'Regresar',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ),
        ),
      ],
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
            if (_selectedVenta == null) ...[
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
            ],
            Expanded(
              child: FutureBuilder<List<ProcesoVentaViewModel>>(
                future: _procesosventaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                    );
                  } else if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
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
                    if (_selectedVenta != null) {
                      return VentaDetalles(_selectedVenta!);
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
