import 'dart:math';
import 'dart:ui';

import 'package:digital_clock/model/split_square_model.dart';
import 'package:flutter/material.dart';

class SquaresManager {
  static final SquaresManager _instance = SquaresManager._internal();

  factory SquaresManager() => _instance;

  SquaresManager._internal() {}

  final int _maxDepth = 13;
  final int _minDepth = 9;
  BoxConstraints _constraints;
  final _random = Random();
  List<Color> _colors;

  set colors(List<Color> value) {
    _colors = value.length > 1 ? value : null;
    reloadTime();
  }

  bool get watchFaceComplete {
    return squares.every((s) => s.complete == true);
  }

  bool _initDone = false;

  List<SplitSquareModel> squares = List<SplitSquareModel>();

  Future<bool> init(BoxConstraints constraints) async {
    if (!_initDone) {
      _constraints = constraints;
      squares.add(SplitSquareModel(
          Rect.fromPoints(Offset.zero,
              Offset(_constraints.maxWidth, _constraints.maxHeight)),
          _randomColor(),
          0));
      _initDone = true;
    }
    return true;
  }

  void reloadTime() {
    squares.clear();
    squares.add(SplitSquareModel(
        Rect.fromPoints(
            Offset.zero, Offset(_constraints.maxWidth, _constraints.maxHeight)),
        _colors != null ? _colors[0] : Colors.white,
        0));
  }

  void updateSplit() {
    var squaresToUpdate = squares
        .where((s) => s.animationInProgress == true || s.goTransparent == true)
        .toList();
    squaresToUpdate.forEach((s) => s.updateAnimation(0.04));
    //if (squaresToUpdate.length > 0) notifyListeners();
  }

  void markForSplit(Path path, List<Offset> pieces) {
    squares.where((s) => s.idle == true).forEach((square) {
      if (square.depth >= _maxDepth) {
        square.lifeCycleState = SquareLifeCycleTypes.complete;
      } else {
        if (_random.nextDouble() > 0.9) {
          if (_allEdgesInPath(path, square.getRect[0])) {
            if (square.depth < _minDepth) {
              square.splitColor = _randomColor();
              square.lifeCycleState = SquareLifeCycleTypes.animationInProgress;
            } else {
              square.lifeCycleState = SquareLifeCycleTypes.complete;
            }
          } else if (_pathInRect(pieces, square.getRect[0])) {
            square.splitColor = _randomColor();
            square.lifeCycleState = SquareLifeCycleTypes.animationInProgress;
          } else {
            square.lifeCycleState = SquareLifeCycleTypes.goTransparent;
            square.splitColor = Colors.transparent;
            //square.color = Colors.transparent;
          }
        }
      }
    });
  }

  void cleanUp() {
    List<SplitSquareModel> removals = List<SplitSquareModel>();
    List<SplitSquareModel> adds = List<SplitSquareModel>();
    squares.where((s) => s.animationDone == true).forEach((square) {
      removals.add(square);
      adds.addAll(square.splitAuto());
    });
    squares.removeWhere((e) => removals.contains(e));
    squares.addAll(adds);
    //if (removals.length > 0 || adds.length>0) notifyListeners();
  }

  bool _allEdgesInPath(Path path, Rect rect) {
    return (path.contains(rect.topLeft) &&
        path.contains(rect.topRight) &&
        path.contains(rect.bottomRight) &&
        path.contains(rect.bottomLeft));
  }

  bool _pathInRect(List<Offset> pieces, Rect rect) {
    for (final point in pieces) {
      if (rect.contains(point)) {
        return true;
      }
    }
    return false;
  }

  Color _randomColor() {
    return _colors != null
        ? _colors[1 + _random.nextInt(_colors.length - 1)]
        : Colors.pink;
  }
}
