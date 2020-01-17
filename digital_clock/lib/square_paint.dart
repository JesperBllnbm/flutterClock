import 'package:digital_clock/model/split_square_model.dart';
import 'package:flutter/material.dart';

class SquarePaint extends CustomPainter {
  final List<SplitSquareModel> squares;

  SquarePaint(this.squares);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint();
    paint.style = PaintingStyle.fill;
    for (var square in squares) {
      paint.color = square.color;
      List<Rect> drawRects;
      drawRects = square.getRect;
      if (drawRects.length > 1) {
        canvas.drawRect(drawRects[0], paint);
        paint.color = square.splitColor;
        canvas.drawRect(drawRects[1], paint);
      } else {
        canvas.drawRect(drawRects[0], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
