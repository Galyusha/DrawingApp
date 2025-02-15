import 'package:drawing_app/features/draw/models/offset.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'stroke.g.dart';

@HiveType(typeId: 1)
class Stroke extends HiveObject {
  @HiveField(0)
  final List<OffsetCustom> points;

  @HiveField(1)
  final int color;

  @HiveField(2)
  final double brushSize;

  Stroke({
    required List<Offset> points, 
    required Color color, 
    required this.brushSize
    }) : points = points.map((e) => OffsetCustom.fromOffset(e)).toList(),
         color = color.value;
    List<Offset> get offsetPoints => points.map((e) => e.toOffset()).toList();

    Color get strokeColor => Color(color);
}