import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    // socketService.socket.on('bandas-activas', (payload) => _manejadorBandasActivas); // mejor abajo
    socketService.socket.on('bandas-activas', _manejadorBandasActivas);
    super.initState();
  }

  _manejadorBandasActivas(dynamic payload) {
    // Se toman las bandas enviadas por el server que vienen con un formato
    // consistente en una lista de mapas [{},{},··{}]
    // y se formatean de este modo:
    bands = (payload as List)
        .map((banda) => Band.fromMap(banda)) // se parsea: metodo fromMap de la clase
        .toList(); // se pasa a lista
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bandas-activas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            width: double.infinity,
            height: 240,
            child: _mostrarGrafica(),
          ),
          Expanded(
            // el Listview.builder dentro de una columna necesita un Expanded
            // sino no se ve bien
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band banda) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    // no hace falta que se redibuje el widget cuando cambia algo del provider
    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => socketService.socket.emit('eliminar-banda', {'id': banda.id}),
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.only(right: 10.0),
        child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.delete_outlined, color: Colors.white),
                SizedBox(width: 5),
                Text('Eliminar', style: TextStyle(color: Colors.white)),
              ],
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(banda.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(banda.name),
        trailing: Text(
          '${banda.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('votar-banda', {'id': banda.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    const String tituloDialogo = 'Nueva Banda';
    const String txtBotonAdd = 'Añadir';
    const String txtBotonCancelar = 'Cancelar';
    // diferentes dialogos para iOS vs Android
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text(tituloDialogo),
            content: TextField(controller: textController),
            actions: [
              MaterialButton(
                child: const Text(txtBotonAdd),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addNewBandToList(textController.text),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text(tituloDialogo),
              content: CupertinoTextField(controller: textController),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text(txtBotonAdd),
                    onPressed: () => addNewBandToList(textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text(txtBotonCancelar),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          });
    }
  }

  void addNewBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('nueva-banda', {'name': name});
    }
    Navigator.pop(context); // se cierra el Dialog
  }

  Widget _mostrarGrafica() {
    // Map<String, double> dataMap = {};
    // dataMap = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };
    Map<String, double> dataMap = {
      for (Band e in bands)
        if (e.votes != null)
          if (e.votes! > 0) e.name: e.votes!.toDouble()
    };
    // bands.forEach((banda) {
    //   dataMap.putIfAbsent(banda.name, () => banda.votes!.toDouble());
    // });
    if (dataMap.isNotEmpty) {
      return PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        // chartRadius: MediaQuery.of(context).size.width / 2,
        // initialAngleInDegree: 0,
        chartType: ChartType.ring,
        // ringStrokeWidth: 12,
        // centerText: "BANDAS",
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      );
    } else {
      return const Center(
        child: Text('No hay datos'),
      );
    }
  }
}
