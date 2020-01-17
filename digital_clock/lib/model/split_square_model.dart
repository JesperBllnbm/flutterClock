import 'package:flutter/material.dart';
import 'dart:math';

enum SquareLifeCycleTypes {
  idle,
  animationInProgress,
  animationDone,
  goTransparent,
  complete
}

class SplitSquareModel {
  final Rect _rect;
  final int depth;
  final random = Random();
  Color _color = Colors.pink;
  Color _splitColor = Colors.pink;
  AxisDirection _splitDirection;
  SquareLifeCycleTypes _lifeCycleState = SquareLifeCycleTypes.idle;
  double _animationValue = 0;
  Curve _animationCurve = Curves.easeInOutQuint;

  bool get animationInProgress =>
      _lifeCycleState == SquareLifeCycleTypes.animationInProgress;

  bool get animationDone =>
      _lifeCycleState == SquareLifeCycleTypes.animationDone;

  bool get complete => _lifeCycleState == SquareLifeCycleTypes.complete;

  bool get goTransparent =>
      _lifeCycleState == SquareLifeCycleTypes.goTransparent;

  bool get idle => _lifeCycleState == SquareLifeCycleTypes.idle;

  set lifeCycleState(SquareLifeCycleTypes value) => _lifeCycleState = value;

  double get animationValue => _animationCurve.transform(_animationValue);

  Color get color => _color;

  Color get splitColor => _splitColor;

  set splitColor(value) => _splitColor = value;

  List<Rect> get getRect =>
      _lifeCycleState == SquareLifeCycleTypes.animationInProgress
          ? splitAutoAnimated()
          : _lifeCycleState == SquareLifeCycleTypes.goTransparent
              ? goTransparentAutoAnimated()
              : [_rect];

  SplitSquareModel(Rect rect, Color color, this.depth)
      : this._rect = rect,
        this._color = color,
        this._splitDirection = rect.longestSide == rect.width
            ? Random().nextBool() ? AxisDirection.left : AxisDirection.right
            : Random().nextBool() ? AxisDirection.up : AxisDirection.down;

  void updateAnimation(double step) {
    _animationValue = (_animationValue + step).clamp(0.0, 1.0);
  }

  List<SplitSquareModel> _splitVerticalRight() {
    Rect newRectRight =
        Rect.fromLTRB(_rect.topCenter.dx, _rect.top, _rect.right, _rect.bottom);
    Rect newRectLeft =
        Rect.fromLTRB(_rect.left, _rect.top, _rect.topCenter.dx, _rect.bottom);

    return [
      SplitSquareModel(newRectLeft, color, this.depth + 1),
      SplitSquareModel(newRectRight, splitColor, this.depth + 1)
    ];
  }

  List<SplitSquareModel> _splitVerticalLeft() {
    Rect newRectRight =
        Rect.fromLTRB(_rect.topCenter.dx, _rect.top, _rect.right, _rect.bottom);
    Rect newRectLeft =
        Rect.fromLTRB(_rect.left, _rect.top, _rect.topCenter.dx, _rect.bottom);

    return [
      SplitSquareModel(newRectLeft, splitColor, this.depth + 1),
      SplitSquareModel(newRectRight, color, this.depth + 1)
    ];
  }

  List<SplitSquareModel> _splitHorizontalUp() {
    Rect newRectTop =
        Rect.fromLTRB(_rect.left, _rect.top, _rect.right, _rect.centerLeft.dy);
    Rect newRectBottom = Rect.fromLTRB(
        _rect.left, _rect.centerLeft.dy, _rect.right, _rect.bottom);
    return [
      SplitSquareModel(newRectTop, color, this.depth + 1),
      SplitSquareModel(newRectBottom, splitColor, this.depth + 1)
    ];
  }

  List<SplitSquareModel> _splitHorizontalDown() {
    Rect newRectTop =
        Rect.fromLTRB(_rect.left, _rect.top, _rect.right, _rect.centerLeft.dy);
    Rect newRectBottom = Rect.fromLTRB(
        _rect.left, _rect.centerLeft.dy, _rect.right, _rect.bottom);
    return [
      SplitSquareModel(newRectTop, splitColor, this.depth + 1),
      SplitSquareModel(newRectBottom, color, this.depth + 1)
    ];
  }

  List<Rect> _splitVerticalRightAnimated() {
    if (_animationValue == 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.animationDone;
    }
    Rect newRectLeft = Rect.fromLTRB(_rect.left, _rect.top,
        _rect.right - (_rect.width * animationValue / 2), _rect.bottom);
    Rect newRectRight = Rect.fromLTRB(
        _rect.right - (_rect.width * animationValue / 2),
        _rect.top,
        _rect.right,
        _rect.bottom);

    return [newRectLeft, newRectRight];
  }

  List<Rect> _splitVerticalLeftAnimated() {
    if (_animationValue == 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.animationDone;
    }

    Rect newRectRight = Rect.fromLTRB(
        _rect.left + (_rect.width * animationValue / 2),
        _rect.top,
        _rect.right,
        _rect.bottom);
    Rect newRectLeft = Rect.fromLTRB(_rect.left, _rect.top,
        _rect.left + (_rect.width * animationValue / 2), _rect.bottom);

    return [newRectRight, newRectLeft];
  }

  List<Rect> _splitHorizontalUpAnimated() {
    if (_animationValue == 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.animationDone;
    }
    Rect newRectTop = Rect.fromLTRB(_rect.left, _rect.top, _rect.right,
        _rect.bottom - (_rect.height * animationValue / 2));
    Rect newRectBottom = Rect.fromLTRB(
        _rect.left,
        _rect.bottom - (_rect.height * animationValue / 2),
        _rect.right,
        _rect.bottom);

    return [newRectTop, newRectBottom];
  }

  List<Rect> _splitHorizontalDownAnimated() {
    if (_animationValue == 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.animationDone;
    }
    Rect newRectBottom = Rect.fromLTRB(
        _rect.left,
        _rect.top + (_rect.height * animationValue / 2),
        _rect.right,
        _rect.bottom);
    Rect newRectTop = Rect.fromLTRB(_rect.left, _rect.top, _rect.right,
        _rect.top + (_rect.height * animationValue / 2));

    return [newRectBottom, newRectTop];
  }

  List<Rect> _goTransparentRightAnimated() {
    Rect newRectLeft = Rect.fromLTRB(_rect.left, _rect.top,
        _rect.right - (_rect.width * animationValue), _rect.bottom);
    Rect newRectRight = Rect.fromLTRB(
        _rect.right - (_rect.width * animationValue),
        _rect.top,
        _rect.right,
        _rect.bottom);
    if (_animationValue >= 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.complete;
      _color = Colors.transparent;
      _splitColor = Colors.transparent;
    }
    return [newRectLeft, newRectRight];
  }

  List<Rect> _goTransparentLeftAnimated() {
    Rect newRectRight = Rect.fromLTRB(
        _rect.left + (_rect.width * animationValue),
        _rect.top,
        _rect.right,
        _rect.bottom);
    Rect newRectLeft = Rect.fromLTRB(_rect.left, _rect.top,
        _rect.left + (_rect.width * animationValue), _rect.bottom);
    if (_animationValue >= 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.complete;
      _color = Colors.transparent;
      _splitColor = Colors.transparent;
    }
    return [newRectRight, newRectLeft];
  }

  List<Rect> _goTransparentUpAnimated() {
    Rect newRectTop = Rect.fromLTRB(_rect.left, _rect.top, _rect.right,
        _rect.bottom - (_rect.height * animationValue));
    Rect newRectBottom = Rect.fromLTRB(
        _rect.left,
        _rect.bottom - (_rect.height * animationValue),
        _rect.right,
        _rect.bottom);
    if (_animationValue >= 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.complete;
      _color = Colors.transparent;
      _splitColor = Colors.transparent;
    }
    List<Rect> res = [newRectTop, newRectBottom];
    return res;
  }

  List<Rect> _goTransparentDownAnimated() {
    Rect newRectBottom = Rect.fromLTRB(_rect.left,
        _rect.top + (_rect.height * animationValue), _rect.right, _rect.bottom);
    Rect newRectTop = Rect.fromLTRB(_rect.left, _rect.top, _rect.right,
        _rect.top + (_rect.height * animationValue));
    if (_animationValue >= 1.0) {
      _lifeCycleState = SquareLifeCycleTypes.complete;
      _color = Colors.transparent;
      _splitColor = Colors.transparent;
    }
    return [newRectBottom, newRectTop];
  }

  List<SplitSquareModel> splitRandom() {
    if (_rect.longestSide / _rect.shortestSide > 4) {
      return splitAuto();
    }
    if (random.nextDouble() > 0.5) {
      return _splitVerticalRight();
    } else {
      return _splitHorizontalUp();
    }
  }

  List<SplitSquareModel> splitAuto() {
    if (_rect.longestSide == _rect.width) {
      //horizontal orientation
      return _splitDirection == AxisDirection.left
          ? _splitVerticalLeft()
          : _splitVerticalRight();
    } else {
      //vertical orientation
      return _splitDirection == AxisDirection.down
          ? _splitHorizontalDown()
          : _splitHorizontalUp();
    }
  }

  List<Rect> splitAutoAnimated() {
    if (_rect.longestSide == _rect.width) {
      //horizontal orientation
      return _splitDirection == AxisDirection.left
          ? _splitVerticalLeftAnimated()
          : _splitVerticalRightAnimated();
    } else {
      //vertical orientation
      return _splitDirection == AxisDirection.down
          ? _splitHorizontalDownAnimated()
          : _splitHorizontalUpAnimated();
    }
  }

  List<Rect> goTransparentAutoAnimated() {
    if (_rect.longestSide == _rect.width) {
      //horizontal orientation
      return _splitDirection == AxisDirection.left
          ? _goTransparentLeftAnimated()
          : _goTransparentRightAnimated();
    } else {
      //vertical orientation
      return _splitDirection == AxisDirection.down
          ? _goTransparentDownAnimated()
          : _goTransparentUpAnimated();
    }
  }
}
