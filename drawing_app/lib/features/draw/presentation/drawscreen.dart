import 'dart:core';
import 'dart:typed_data';

import 'package:drawing_app/features/draw/models/stroke.dart';
import 'package:drawing_app/features/draw/utils/thumbnail_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Drawscreen extends StatefulWidget {
  const Drawscreen({super.key});

  @override
  State<Drawscreen> createState() => _DrawscreenState();
}

class _DrawscreenState extends State<Drawscreen> {
  List<Stroke> _strokes = [];
  List<Stroke> _redoStokes = [];
  List<Offset> _currentPoints = [];
  Color _selectedColor = Colors.black;
  double _brushSize = 4.0;
  late Box<Map<String, dynamic>> _drawingBox;
  String? _drawingName;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHive();
    });

    super.initState();
  }

  Future<void> _initializeHive() async {
    _drawingBox = Hive.box<List<Stroke>>('drawings') as Box<Map<String, dynamic>>;

    final name = ModalRoute.of(context)?.settings.arguments as String?;
    if (name != null) {
      final rawData = _drawingBox.get(name);
      setState(() {
        _drawingName = name;
        _strokes = (rawData?['strokes'] as List<dynamic>?)?.cast<Stroke>() ?? [];
      });
    }
   }

   Future<void> _saveDrawing(String name) async{
    //Generate thumbnail
     final Uint8List thumbnail = await generateThumbnail(_strokes, 200, 200);
    await _drawingBox.put(name,{
        'strokes': _strokes,
    'thumbnail': thumbnail});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Drawing $name saved!"),)
    );
   }

   void _showSaveDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog (
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Save Drawing"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter drawing name"),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
            TextButton(
                onPressed: () {
                  final name = _controller.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      _drawingName = name;
                    });
                    _saveDrawing(name);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save")
            ),
          ],
        );
      }
    );
   }

   @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_drawingName ?? "Draw Your Dream"),
      ),
      body: Column(children: [
        Expanded(child:
        GestureDetector(
          onPanStart: (details) {
            setState(() {
              _currentPoints.add(details.localPosition);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _currentPoints.add(details.localPosition);
            });
          },
          onPanEnd: (details) {
            setState(() {
              _strokes.add(
                Stroke.fromOffsets(
                  points: List.from(_currentPoints),
                  color: _selectedColor,
                  brushSize: _brushSize)
              );
              _currentPoints = [];
              _redoStokes = [];
            });
          },
          child: CustomPaint(
            painter: DrawPainter(
              strokes: _strokes,
              currentPoints: _currentPoints,
              currentColor: _selectedColor,
              currentBrushSize: _brushSize
            ),
          )

          )
        ),
        _buildToolBar(),
      ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showSaveDialog,
          child: const Icon(Icons.save)
      ),
    );
  }

  Widget _buildToolBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // undo button
          IconButton(
            onPressed: _strokes.isNotEmpty ? (){
              setState(() {
                _redoStokes.add(_strokes.removeLast());
              });
            } : null,
            icon: const Icon(Icons.undo)
            ),
          IconButton(
            onPressed: _redoStokes.isNotEmpty ? (){
              setState(() {
                _strokes.add(_redoStokes.removeLast());
              });
            } : null,
            icon: const Icon(Icons.redo)
            ),

            //Brush Size dropdown
          DropdownButton(
            value: _brushSize,
            items: [
              DropdownMenuItem (
                value: 2.0,
                child:
                  Text('Small')
              ),
              DropdownMenuItem (
                value: 4.0,
                child:
                  Text('Medium')
              ),
              DropdownMenuItem (
                value: 8.0,
                child:
                  Text('Large')
              ),
            ],
             onChanged: (value){
              setState(() {
                _brushSize = value!;
              });
             }),
             // Color picker
             Row(children: [
              _buildColorButton(Colors.black),
              _buildColorButton(Colors.red),
              _buildColorButton(Colors.blue),
              _buildColorButton(Colors.green),
              _buildColorButton(Colors.pink)
             ],)
      ],)
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all
          (color: _selectedColor == color ? Colors.grey : Colors.transparent, width: 2
          )
        )
        )
    );
  }
  
}

class DrawPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentBrushSize;

  DrawPainter({super.repaint, required this.strokes, required this.currentPoints, required this.currentColor, required this.currentBrushSize});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.strokeColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.brushSize;

      final points = stroke.offsetPoints;
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
          canvas.drawLine(points[i], points[i + 1], paint);
        }
      }
    }

    // Draw the current active stroke
    final paint = Paint()
      ..color = currentColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentBrushSize;

    for (int i = 0; i < currentPoints.length - 1; i++) {
        if (currentPoints[i] != Offset.zero && currentPoints[i + 1] != Offset.zero) {
          canvas.drawLine(currentPoints[i], currentPoints[i + 1], paint);
        }
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}
