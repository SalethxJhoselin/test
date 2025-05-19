import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:medical_record_movil/components/customAppBar.dart';
import 'package:medical_record_movil/services/laboratorioService.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/userProvider.dart';

class LaboratoriosPage extends StatefulWidget {
  const LaboratoriosPage({super.key});

  @override
  LaboratoriosPageState createState() => LaboratoriosPageState();
}

class LaboratoriosPageState extends State<LaboratoriosPage> {
  late Future<List<Map<String, dynamic>>> _futureLaboratorios;

  @override
  void initState() {
    super.initState();
    _futureLaboratorios = _loadLaboratorios();
  }

  Future<List<Map<String, dynamic>>> _loadLaboratorios() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.id;

    if (userId != null) {
      try {
        return await LaboratorioService.getLaboratorios(userId);
      } catch (e) {
        debugPrint('Error al cargar laboratorios: $e');
        return [];
      }
    } else {
      debugPrint('El usuario no está autenticado.');
      return [];
    }
  }

  Future<void> _downloadReport() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.id;

    if (userId != null) {
      try {
        final bytes =
            await LaboratorioService.downloadLaboratorioReport(userId);
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/reporte_laboratorios_$userId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reporte guardado en: $filePath'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar el reporte: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El usuario no está autenticado.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title1: 'Mis Laboratorios',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Color.fromARGB(255, 207, 230, 253),
        titlecolor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureLaboratorios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron laboratorios'),
            );
          }

          final laboratorios = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 207, 230, 253),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      LineAwesomeIcons.download_solid,
                      color: Colors.black,
                    ),
                    onPressed: _downloadReport,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: laboratorios
                        .map((laboratorio) => buildLaboratorioCard(laboratorio))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildLaboratorioCard(Map<String, dynamic> lab) {
    String formatFecha(List<dynamic>? fecha) {
      if (fecha != null && fecha.length == 3) {
        final date = DateTime(fecha[0], fecha[1], fecha[2]);
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return 'Desconocido';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 68, 85, 102),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lab['tipo_examen'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LineAwesomeIcons.angle_right_solid,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow(
                    'Fecha de Examen', formatFecha(lab['fecha_examen'])),
                const Divider(),
                buildInfoRow('Observaciones', lab['observaciones']),
                const Divider(),
                buildEstadoChip('Estado', lab['estado']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: Colors.black38,
          ),
        ),
        Expanded(
          child: Text(
            value ?? '',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEstadoChip(String title, String? estado) {
    Color estadoColor = Colors.grey;

    switch (estado) {
      case 'Finalizado':
        estadoColor = Colors.green;
        break;
      case 'Pendiente':
        estadoColor = Colors.orange;
        break;
      case 'Cancelado':
        estadoColor = Colors.red;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: Colors.black38,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            estado ?? 'Desconocido',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: estadoColor,
            ),
          ),
        ),
      ],
    );
  }
}
