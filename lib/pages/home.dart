import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'U2', votes: 5),
    Band(id: '2', name: 'Guns & Roses', votes: 5),
    Band(id: '3', name: 'Creedence', votes: 4),
    Band(id: '4', name: 'The Smiths', votes: 1),
    Band(id: '5', name: 'Oasis', votes: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band banda) {
    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direccion) {
        // TODO: borrar en server
        print(direccion);
      },
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
//      onDismissed: (){},
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
        onTap: () {},
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
        builder: (context) {
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
      bands.add(Band(
        id: DateTime.now().toString(),
        name: name,
        votes: 0,
      ));
      setState(() {});
    }
    Navigator.pop(context); // se cierra el Dialog
  }
}
