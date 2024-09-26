import 'package:flutter/material.dart'; 
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import '../.././services/apiservice.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int usua_Id;
  late String _usuaUsuario = "";
  late String _empleado = "";
  late String _correo = "";
  late String _telfono = "";
  late String _cargo = "";
  ImageProvider _profileImage = AssetImage('lib/assets/perfil.jpeg');

  bool _isEditingEmail = false;
  bool _machclave = false;
  bool _confirmarclave = false;
  bool _passwordSubmitted = false;
  bool _emailSubmitted = false;
  bool _isEmailValid = true; // Nueva variable para la validación del email

  TextEditingController _emailController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    var prefs = PreferenciasUsuario();
    usua_Id = int.tryParse(prefs.userId) ?? 0;
    _usuaUsuario = prefs.usernombre;
    _empleado = prefs.usernombre;
    _usuaUsuario = prefs.nombreusuario;
    _correo = prefs.userCorreo;
    _telfono = prefs.userTelefono;
    _cargo = prefs.userCargo;

    String imageUrl2 = prefs.userImagenEmpleado;
    final baseUrl = Uri.parse('${ApiService.apiUrl}/Empleado');

    if (imageUrl2.isNotEmpty) {
      String imageUrl = "$baseUrl$imageUrl2";
      _profileImage = NetworkImage(imageUrl);
    } else {
      _profileImage = AssetImage('lib/assets/usuario.jpg');
    }

    _emailController.text = _correo;
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
            final screenWidth = MediaQuery.of(context).size.width;
            return AlertDialog(
              backgroundColor: Color(0xFF171717),
              title: Text(
                'Cambiar Contraseña',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
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
                      errorText: _passwordSubmitted &&
                              _currentPasswordController.text.isEmpty
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
                      errorText: _passwordSubmitted &&
                              _newPasswordController.text.isEmpty
                          ? 'El campo es requerido.'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _machclave = _newPasswordController.text !=
                            _confirmPasswordController.text;
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
                      errorText: _passwordSubmitted &&
                              (_confirmPasswordController.text.isEmpty ||
                                  _machclave)
                          ? _confirmPasswordController.text.isEmpty
                              ? 'El campo es requerido.'
                              : 'Las contraseñas deben coincidir'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _confirmarclave = true;
                        _machclave =
                            _newPasswordController.text != value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: ElevatedButton(
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
                            int? result =
                                await UsuarioService.Restablecerflutter(
                              usua_Id,
                              _currentPasswordController.text,
                              _newPasswordController.text,
                            );

                            Navigator.of(context).pop();
                            if (result != null && result == 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Actualizado con Éxito.')),
                              );
                              // Limpiar los campos de contraseñas
                              _currentPasswordController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                              setState(() {
                                _passwordSubmitted = false;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Contraseña actual inválida.')),
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error al actualizar la contraseña.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFF0C6),
                          textStyle: TextStyle(fontSize: 14),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenWidth * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, color: Colors.black),
                            SizedBox(width: 6),
                            Text('Guardar',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: ElevatedButton(
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
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenWidth * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, color: Color(0xFFFFF0C6)),
                            SizedBox(width: 6),
                            Text('Cancelar',
                                style: TextStyle(color: Color(0xFFFFF0C6))),
                          ],
                        ),
                      ),
                    ),
                  ],
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

    String email = _emailController.text;
    
    // Validación del formato de correo electrónico para que tenga solo un @ y un dominio válido (.com, .es, etc.)
    _isEmailValid = RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(email);

    if (email.isEmpty) {
      setState(() {
        _isEmailValid = false;
      });
      return;
    }

    if (!_isEmailValid) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF171717),
          title: Text('Confirmación', style: TextStyle(color: Colors.white)),
          content: Text(
              '¿Estás seguro de querer cambiar tu correo electrónico?',
              style: TextStyle(color: Colors.white)),
          actions: [
            ElevatedButton(
              onPressed: () async {
                int? result = await UsuarioService.Restablecercorreo(usua_Id, email);

                Navigator.of(context).pop();
                if (result != null && result == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Actualizado con Éxito.')),
                  );
                  
                  setState(() {
                    var prefs = PreferenciasUsuario();
                    prefs.userCorreo = email;  // Guardar el nuevo correo en preferencias
                    _correo = email;
                    _emailController.text = email;
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
                textStyle: TextStyle(fontSize: 15),
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.width * 0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Aceptar', style: TextStyle(color: Colors.black)),
                ],
              ),
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
                textStyle: TextStyle(fontSize: 15),
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.width * 0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, color: Color(0xFFFFF0C6)),
                  SizedBox(width: 8),
                  Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (_isEditingEmail) {
          _confirmEmailChange();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leadingWidth: screenWidth * 0.25, // Ajuste dinámico
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                SizedBox(width: 8),
                Icon(Icons.arrow_back, color: Color(0xFFFFF0C6)),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Regresar',
                    style: TextStyle(
                        color: Color(0xFFFFF0C6), fontSize: screenWidth * 0.04),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          title: Text('Perfil', style: TextStyle(color: Color(0xFFFFF0C6))),
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFFFF0C6)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.02),
              ClipOval(
                child: Image(
                  image: _profileImage,
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                _usuaUsuario,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _cargo,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: _showChangePasswordModal,
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: screenWidth * 0.04),
                ),
                child: Text('Cambiar Contraseña'),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: TextEditingController(text: _empleado),
                style: TextStyle(color: Colors.white),
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF171717),
                  hintText: "Nombre",
                  hintStyle: TextStyle(
                      color: Colors.grey, fontSize: screenWidth * 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                controller: TextEditingController(text: _telfono),
                style: TextStyle(color: Colors.white),
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF171717),
                  hintText: "Teléfono",
                  hintStyle: TextStyle(
                      color: Colors.grey, fontSize: screenWidth * 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
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
                      hintStyle: TextStyle(
                          color: Colors.grey, fontSize: screenWidth * 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: _isEditingEmail
                              ? Colors.blue
                              : Colors.transparent,
                          width: _isEditingEmail ? 2.0 : 1.0,
                        ),
                      ),
                      errorText: _emailSubmitted && !_isEmailValid
                          ? 'El correo electrónico no es válido. Debe contener un @ y un dominio (.com, .es, etc.).'
                          : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
