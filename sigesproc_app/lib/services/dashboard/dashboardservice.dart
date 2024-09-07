import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import '../apiservice.dart';

class RespuestaSoloMensaje {
  final String? message;

  RespuestaSoloMensaje({this.message});

  // Factory constructor para crear una instancia desde el JSON
  factory RespuestaSoloMensaje.fromJson(Map<String, dynamic> json) {
    return RespuestaSoloMensaje(
      message: json['message'],
    );
  }
}

class DashboardService {
  // Method to list top 5 providers
  static Future<List<ProveedorViewModel>> listarTop5Proveedores() async {
    final url =
        Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardTop5Proveedores');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProveedorViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<DashboardArticulosViewModel>> listarTop5ArticulosComprados() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardTop5ArticulosCompradoss');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardArticulosViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
  // Method to list top 5 most purchased articles
  // static Future<List<DashboardViewModel>> listarTop5ArticulosComprados() async {
  //   final url = Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardTop5ArticulosCompradoss');
  //   final response = await http.get(url, headers: ApiService.getHttpHeaders());

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => DashboardViewModel.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Error al cargar los datos');
  //   }
  // }

  // Method to get monthly purchase totals
  static Future<List<ComprasMesViewModel>>
      listarTotalesComprasMensuales() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardTotalesComprasMensuales');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ComprasMesViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to list related projects
  static Future<List<TopProyectosRelacionadosViewModel>> listarProyectosRelacionados() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardProyectosRelacionados');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TopProyectosRelacionadosViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to list top 5 destination warehouses
  static Future<List<TopNumeroDestinosFletesViewModel>> listarTop5BodegasDestino() async {
    final url =
        Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardTop5BodegasDestino');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TopNumeroDestinosFletesViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to get freight incidence rates
  static Future<List<DashboardViewModel>> listarFletesTasaIncidencias() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardFletesTasaIncidencias');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to list sales by agent
  static Future<List<VentasPorAgenteViewModel>> listarVentasPorAgente() async {
    final url =
        Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardVentasPorAgente');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => VentasPorAgenteViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }


  static Future<List<DashboardBienRaizViewModel>> ventamensualbienraiz() async {
    final url = Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardVentaMensualBienRaiz');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardBienRaizViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }




    static Future<List<VentaTerrenoViewModel>> ventamensualterreno() async {
    final url = Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardVentaMensualTerreno');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => VentaTerrenoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }


  // Method to list lands by month
  static Future<List<DashboardViewModel>> listarTerrenosPorMees() async {
    final url =
        Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardTerrenosPorMees');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to list top 5 projects with the highest budget
  static Future<List<DashboardProyectoViewModel>>
      listarTop5ProyectosMayorPresupuesto() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardTop5ProyectosMayorPresupuesto');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardProyectoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to list project details by department
  static Future<DashboardViewModel> listarProyectosPorDepartamentoDetalle(
      int id) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardProyectosPorDepartamentoteDetalle/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      return DashboardViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Method to list debts by employee
  static Future<DashboardViewModel> listarDeudasPorEmpleado(int id) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardDeudasPorEmpleado/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      return DashboardViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<BancoAcreditacionesViewModel>> listarTop5Bancos() async {
    final url = Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardTop5Bancos');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

   if (response.statusCode == 200) {
  List<dynamic> data = json.decode(response.body);
  return data.map((json) => BancoAcreditacionesViewModel.fromJson(json)).toList();
} else {
  throw Exception('Error al cargar los datos');
}
  }

  static Future<List<ViaticosMesActualViewModel>> listarPrestamosViaticosMes() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardPrestamoViaticosMes');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ViaticosMesActualViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<DashboardPrestamoDiasMesViewModel>> listarPrestamosMesDias() async {
    final url =
        Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardPrestamoMes');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardPrestamoDiasMesViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<DepartamentoViewModel>> ProyectosPorDepartamento() async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Dashboard/DashboardProyectosPorDepartamentos');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DepartamentoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
