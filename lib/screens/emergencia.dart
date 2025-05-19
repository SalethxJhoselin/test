import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:medical_record_movil/components/BottonChange.dart';
import 'package:medical_record_movil/components/inputChange.dart';

import '../components/customAppBar.dart';

class EmergenciaMedicaPage extends StatefulWidget {
  const EmergenciaMedicaPage({super.key});

  @override
  EmergenciaMedicaPageState createState() => EmergenciaMedicaPageState();
}

class EmergenciaMedicaPageState extends State<EmergenciaMedicaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  String? prioridadSeleccionada;

  final List<String> prioridades = ['Alta', 'Media', 'Baja'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title1: 'Emergencia Médica',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Color.fromARGB(255, 207, 230, 253),
        titlecolor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Solicitar Emergencia Médica',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Nombre del Paciente
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: nombreController,
                      decoration: TextFormFieldTheme.customInputDecoration(
                        labelText: 'Nombre del Paciente',
                        context: context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Dirección
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: direccionController,
                      decoration: TextFormFieldTheme.customInputDecoration(
                        labelText: 'Dirección',
                        context: context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Descripción de la Emergencia
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: descripcionController,
                      decoration: TextFormFieldTheme.customInputDecoration(
                        labelText: 'Descripción de la Emergencia',
                        context: context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Campo: Prioridad
                  SizedBox(
                    width: 300,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                      ),
                      value: prioridadSeleccionada,
                      items: prioridades.map((String prioridad) {
                        return DropdownMenuItem<String>(
                          value: prioridad,
                          child: Text(prioridad),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          prioridadSeleccionada = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione la prioridad';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  BottonChange(
                    colorBack: const Color.fromARGB(255, 68, 85, 102),
                    colorFont: Colors.white,
                    textTile: 'Enviar Emergencia',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Acciones al enviar la emergencia
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Emergencia Enviada'),
                            content: const Text(
                                'Se ha enviado la solicitud de emergencia médica correctamente.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    width: 300,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
