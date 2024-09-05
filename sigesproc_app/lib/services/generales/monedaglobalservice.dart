import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/monedaglobalviewmodel.dart';
import '../apiservice.dart';

class MonedaGlobalService {

      // Variable global estática que almacenará la instancia completa de MonedaGlobalViewModel
      static MonedaGlobalViewModel? monedaGlobal;
      // Variable global estática que almacenará solo la abreviatura de la moneda
      static String? monedaAbreviaturaGlobal;


      static Future<MonedaGlobalViewModel> listarFormatoMoneda() async {
        final url = Uri.parse('${ApiService.apiUrl}/Moneda/Buscar/1');
        final response = await http.get(url, headers: ApiService.getHttpHeaders());

        if (response.statusCode == 200) {
          // Decodifica el JSON en un Map
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          
          // Retorna el objeto MonedaGlobalViewModel desde el JSON
          return MonedaGlobalViewModel.fromJson(jsonResponse);
        } else {
          throw Exception('Error al cargar la moneda');
        }
      }


  // Método para inicializar las variables globales
  static Future<void> cargarMonedaGlobal() async {
    try {
      // Cargar los datos de la API
      monedaGlobal = await listarFormatoMoneda();
      
      // Si la moneda global se ha cargado con éxito, extraer la abreviatura
      if (monedaGlobal != null) {
        monedaAbreviaturaGlobal = monedaGlobal!.moneAbreviatura;
      }
    } catch (e) {
      print('Error al cargar la moneda: $e');
    }
  }



  //LLAMAR A ESTE METODO Y ASIGNARSELO A LA VARIABLE QUE LLEVARÁ LA ABREVIATURA DE LA MONEDA COMO VALOR
  //ASI SE ASIGNA: String? abreviatura = await MonedaGlobalService.obtenerAbreviaturaMoneda();
    static Future<String?> obtenerAbreviaturaMoneda() async {
    try {
      // Cargar los datos de la API
      MonedaGlobalViewModel moneda = await listarFormatoMoneda();
      
      // Retornar la abreviatura de la moneda
      return moneda.moneAbreviatura;
    } catch (e) {
      print('Error al cargar la abreviatura de la moneda: $e');
      return null; // En caso de error, retornar null
    }
  }

}
