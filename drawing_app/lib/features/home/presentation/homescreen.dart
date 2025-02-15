import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../draw/models/stroke.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Box<Map<String, dynamic>> _drawingBox;

  @override
  void initState() {
    _initializeHive();
    super.initState();
  }

  Future<void> _initializeHive() async {

    _drawingBox = Hive.box<List<Stroke>>('drawings') as Box<Map<String, dynamic>>;
    setState(() {

    });
  }
  void _deleteDrawing(String name) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Drawing"),
          content: Text("Are you sure you want to delete $name"),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"))
          ]
        ));

    if (confirm == true) {
      _drawingBox.delete(name);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Drawing $name deleted!"),)
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawingNames = _drawingBox.keys.cast<String>().toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drawings'),
        actions: [
          IconButton(onPressed: () async {
            await _drawingBox.deleteFromDisk();
            _drawingBox = await Hive.openBox<Map<String, dynamic>>('drawings');
            setState(() {

            });
          },
              icon: Icon(Icons.delete_forever_outlined))
        ],
      ),
      body: drawingNames.isEmpty
        ? const Center(child: Text("No drawings saved yet"),)
      :


      GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8
        ),
        itemCount: drawingNames.length,
        itemBuilder: (context, index) {
          final name = drawingNames[index];
          final data = _drawingBox.get(name) as Map;
          final thumbnail = data['thumbnail'] as Uint8List;
          return Stack(children: [
            GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                "/draw",
                arguments: name
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child:
                  Image.memory(thumbnail,
                  fit: BoxFit.cover)),
                  Padding(padding: const EdgeInsets.all(5), child:
                  Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                )
                  )
          ]
              )
            )

          ),
            Positioned(
                top: 4,
                right: 4,
                child:
                  IconButton(
                      onPressed: () => _deleteDrawing(name),
                      icon: const Icon(Icons.delete, color: Colors.red,)))
          ]
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/draw');
            setState(() {

            });
            },
          child: Icon(Icons.draw))

    );
  }
}