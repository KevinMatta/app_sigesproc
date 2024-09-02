import 'package:flutter/material.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int usua_Id;
  String _usuaUsuario = "";
  String _empleado = "";
  String _correo = "";
  String _telfono = "";
  String _cargo = "";
  ImageProvider _profileImage = AssetImage('lib/assets/perfil.jpeg');

  bool _isEditingEmail = false;
  bool _machclave = false;
  bool _confirmarclave = false;
  bool _passwordSubmitted = false; 
  bool _emailSubmitted = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    var prefs = PreferenciasUsuario();
    usua_Id = int.tryParse(prefs.userId) ?? 0;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchUserData();  // Cargar los datos después de que la pantalla se haya renderizado
  });
  }

  Future<void> _fetchUserData() async {
    try {
      UsuarioViewModel usuario = await UsuarioService.Buscar(usua_Id);

      setState(() {
        _usuaUsuario = usuario.usuaUsuario ?? "";
        _empleado = usuario.nombreEmpleado ?? "";
        _correo = usuario.correoEmpleado ?? "";
        _telfono = usuario.telefonoEmpleado ?? "";
        _cargo = usuario.cargoDescripcion ?? "";

        _profileImage = (usuario.imagenEmpleado != null && usuario.imagenEmpleado!.isNotEmpty)
            ? NetworkImage(usuario.imagenEmpleado!)
            : AssetImage('lib/assets/perfil.jpeg');

        _emailController.text = _correo;
      });
    } catch (e) {
      print("Error al cargar los datos del usuario: $e");
    }
  }

  void _showOverlayMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFF0C6), 
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF171717),
              title: Text('Cambiar Contraseña', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      errorText: _passwordSubmitted && _currentPasswordController.text.isEmpty
                          ? 'El campo es requerido.'
                          : null,
                    ),
                  ),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      errorText: _passwordSubmitted && _newPasswordController.text.isEmpty
                          ? 'El campo es requerido.'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _machclave = _newPasswordController.text != _confirmPasswordController.text;
                      });
                    },
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                    decoration: InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      errorText: _passwordSubmitted && (_confirmPasswordController.text.isEmpty || _machclave)
                          ? _confirmPasswordController.text.isEmpty
                              ? 'El campo es requerido.'
                              : 'Las contraseñas deben coincidir'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _confirmarclave = true;
                        _machclave = _newPasswordController.text != value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _passwordSubmitted = true; 
                    });

                    if (_currentPasswordController.text.isEmpty ||
                        _newPasswordController.text.isEmpty ||
                        _confirmPasswordController.text.isEmpty ||
                        _machclave) {
                      
                      return;
                    }

                    try {
                      int? result = await UsuarioService.Restablecerflutter(
                        usua_Id, 
                        _currentPasswordController.text,
                        _newPasswordController.text,
                      );

                      Navigator.of(context).pop();
                      if (result != null && result == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Actualizado con Éxito.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contraseña actual inválida.')),
                        );
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar la contraseña.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFF0C6), 
                    textStyle: TextStyle(fontSize: 14), 
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Guardar', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                      _passwordSubmitted = false;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    textStyle: TextStyle(fontSize: 14),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmEmailChange() {
    setState(() {
      _emailSubmitted = true; 
    });

    if (_emailController.text.isEmpty) {
      _showOverlayMessage('El campo es requerido.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF171717),
          title: Text('Confirmación', style: TextStyle(color: Colors.white)),
          content: Text('¿Estás seguro de que quieres cambiar tu correo electrónico?', style: TextStyle(color: Colors.white)),
          actions: [
            ElevatedButton(
              onPressed: () async {
                int? result = await UsuarioService.Restablecercorreo(usua_Id, _emailController.text);

                Navigator.of(context).pop();
                if (result != null && result == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Actualizado con Éxito.')),
                  );
                  setState(() {
                    _correo = _emailController.text;
                    _isEditingEmail = false;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Actualización fallida.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFF0C6), 
                textStyle: TextStyle(fontSize: 14), 
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Aceptar', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isEditingEmail = false;
                  _emailController.text = _correo;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, 
                textStyle: TextStyle(fontSize: 14),
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isEditingEmail) {
          _confirmEmailChange();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Perfil', style: TextStyle(color: Color(0xFFFFF0C6))),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Color(0xFFFFF0C6)), 
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), 
              ClipOval(
                child: Image(
                  image: _profileImage,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
        
              Text(
                _usuaUsuario,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _cargo,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showChangePasswordModal,
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 14),
                ),
                child: Text('Cambiar Contraseña'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: _empleado),
                style: TextStyle(color: Colors.white),
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF171717),
                  hintText: "Nombre",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Stack(
                children: [
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    enabled: _isEditingEmail,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF171717),
                      hintText: "Correo electrónico",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: _isEditingEmail ? Colors.blue : Colors.transparent,
                          width: _isEditingEmail ? 2.0 : 1.0,
                        ),
                      ),
                      errorText: _emailSubmitted && _emailController.text.isEmpty ? 'El campo es requerido.' : null,
                    ),
                    onSubmitted: (value) {
                      _confirmEmailChange();
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 8,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isEditingEmail = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _telfono),
                style: TextStyle(color: Colors.white),
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF171717),
                  hintText: "Teléfono",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
