import 'package:flutter/material.dart';
import 'map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Llamando al componente de Login
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginComponent()),
            );
          },
          child: const Text('Ir al Login'),
        ),
      ),
    );
  }
}

// Componente de Login como un widget separado
class LoginComponent extends StatefulWidget {
  const LoginComponent({super.key});

  @override
  _LoginComponentState createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final _formKey = GlobalKey<FormState>(); 
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de email
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor ingrese un correo válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo de contraseña
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              
              // Botón de iniciar sesión
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    print('Correo: $_email, Contraseña: $_password');

if (_email == 'angel.pesantes@unl.edu.ec' && _password == 'lastorres2000') {
  // Se muestra mensaje de éxito
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Inicio de sesión exitoso')),
  );
  
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => map()),
    );

} else {
  // En caso de existir un error se muestra un mensaje
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Credenciales incorrectas')),
  );
}
                  }
                },
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
