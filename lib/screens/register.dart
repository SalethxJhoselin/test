import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/BottonChange.dart';
import '../providers/userProvider.dart';
import '../services/authService.dart';
import '../utils/assets.dart';
import 'home.dart';
import 'navigation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    Center(
                      child: Container(
                        width: size.width * 0.5,
                        height: size.height * 0.2,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage(Assets.imagesSplash),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Registro de Usuario',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa el formulario para crear tu cuenta.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTextField('Usuario', 'Ingrese su usuario',
                            _usernameController, false),
                        const SizedBox(height: 12),
                        buildTextField('Nombre', 'Ingrese su nombre',
                            _nameController, false),
                        const SizedBox(height: 12),
                        buildTextField('Email', 'Ingrese su email',
                            _emailController, false),
                        const SizedBox(height: 12),
                        buildTextField('Contraseña', 'Ingrese su contraseña',
                            _passwordController, true),
                        const SizedBox(height: 20),
                        BottonChange(
                          colorBack: Colors.teal,
                          colorFont: Colors.white,
                          textTile: 'Registrar',
                          onPressed: _register,
                          width: 300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final username = _usernameController.text;
        final password = _passwordController.text;
        final name = _nameController.text;
        final email = _emailController.text;

        final response = await AutenticacionServices().registerUsuario(
            context: context,
            username: username,
            password: password,
            nombre: name,
            email: email);

        if (response != null) {
          final token = response;
          await userProvider.setToken(token);

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      } catch (e) {}
    }
  }
}

Widget buildTextField(String label, String hint,
    TextEditingController controller, bool isPassword) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color.fromARGB(255, 174, 191, 200)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.blue,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 174, 191, 200),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
    ),
    obscureText: isPassword,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo no puede estar vacío';
      }
      return null;
    },
  );
}
