import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:text_to_path_maker/text_to_path_maker.dart' as ttpm;
import 'package:vector_math/vector_math_64.dart' as vm;

class PathBuilder {
  static final PathBuilder _instance = PathBuilder._internal();

  factory PathBuilder() => _instance;

  PathBuilder._internal() {}

  BoxConstraints _constraints;
  DateTime _dateTime = DateTime.now();

  set dateTime(DateTime t) {
    _dateTime = t;
    _quickUpdatePath();
    _calculateNextPath();
  }

  DateFormat _dateFormat24 = DateFormat("HH:mm");
  DateFormat _dateFormat12 = DateFormat("hh:mm");
  bool _is24HourFormat = false;

  get is24HourFormat => _is24HourFormat;

  Future<bool> _doneFuture;

  bool _initDone = false;

  Future get initializationDone => _doneFuture;

  ttpm.PMFont _myFont;
  Path currentPath;
  Path _nextPath;

  List<Offset> currentPieces = List<Offset>();
  List<Offset> nextPieces = List<Offset>();

  void init(BoxConstraints constraints) async {
    if (!_initDone) {
      ByteData data =
          await rootBundle.load("assets/monospacedWithNormalZero-Bold.ttf");
      var reader = ttpm.PMFontReader();
      // Parse the font
      _myFont = reader.parseTTFAsset(data);
      _constraints = constraints;
      _initPath();
      _initDone = true;
      _doneFuture = Future<bool>.value(true);
    }
  }

  void _initPath() {
    currentPath =
        _myFont.generatePathForCharacter(_asciiCodeTime(0, _dateTime));
    currentPath.addPath(
        _myFont.generatePathForCharacter(_asciiCodeTime(1, _dateTime)),
        Offset(500, 0));
    currentPath.addPath(_myFont.generatePathForCharacter(58), Offset(1000, 0));
    currentPath.addPath(
        _myFont.generatePathForCharacter(_asciiCodeTime(3, _dateTime)),
        Offset(1500, 0));
    currentPath.addPath(
        _myFont.generatePathForCharacter(_asciiCodeTime(4, _dateTime)),
        Offset(2000, 0));

    _nextPath = _myFont.generatePathForCharacter(_asciiCodeTime(0, _dateTime));
    _nextPath.addPath(
        _myFont.generatePathForCharacter(_asciiCodeTime(1, _dateTime)),
        Offset(500, 0));
    _nextPath.addPath(_myFont.generatePathForCharacter(58), Offset(1000, 0));
    _nextPath.addPath(
        _myFont.generatePathForCharacter(_asciiCodeTime(3, _dateTime)),
        Offset(1500, 0));
    _nextPath.addPath(
        _myFont.generatePathForCharacter(_asciiCodeTime(4, _dateTime)),
        Offset(2000, 0));

    currentPath = _moveAndScale(currentPath, 0.9);
    _nextPath = _moveAndScale(_nextPath, 0.9);

    currentPieces = _breakIntoPoints(currentPath, 0.001);
    nextPieces = _breakIntoPoints(_nextPath, 0.001);
  }

  Future set24HourFormat(bool value) async {
    if (value != _is24HourFormat) {
      _is24HourFormat = value;
      _initPath();
      await _calculateNextPath();
    }
  }

  void _quickUpdatePath() {
    currentPath = _nextPath;
    currentPieces = nextPieces;
  }

  Future _calculateNextPath() async {
    _nextPath = _myFont.generatePathForCharacter(
        _asciiCodeTime(0, _dateTime.add(Duration(minutes: 1))));
    _nextPath.addPath(
        _myFont.generatePathForCharacter(
            _asciiCodeTime(1, _dateTime.add(Duration(minutes: 1)))),
        Offset(500, 0));
    _nextPath.addPath(_myFont.generatePathForCharacter(58), Offset(1000, 0));
    _nextPath.addPath(
        _myFont.generatePathForCharacter(
            _asciiCodeTime(3, _dateTime.add(Duration(minutes: 1)))),
        Offset(1500, 0));
    _nextPath.addPath(
        _myFont.generatePathForCharacter(
            _asciiCodeTime(4, _dateTime.add(Duration(minutes: 1)))),
        Offset(2000, 0));

    _nextPath = _moveAndScale(_nextPath, 0.9);
    nextPieces = _breakIntoPoints(_nextPath, 0.001);
    print("next path is ready");
  }

  int _asciiCodeTime(int digit, DateTime dateTime) {
    String timeString = _is24HourFormat
        ? _dateFormat24.format(dateTime)
        : _dateFormat12.format(dateTime);
    return int.parse(timeString[digit]) + 48;
  }

  List<Offset> _breakIntoPoints(Path path, double precision) {
    var metrics = path.computeMetrics();
    List<Offset> points = [];
    metrics.forEach((metric) {
      for (var i = 0.0; i < 1.1; i += precision) {
        points.add(metric.getTangentForOffset(metric.length * i).position);
      }
    });
    return points;
  }

  Path _moveAndScale(Path path, double horizontalRelativePadding) {
    Rect boundRect = path.getBounds();
    double scale = (_constraints.maxWidth * horizontalRelativePadding) /
        boundRect.longestSide;
    vm.Matrix4 tScale = vm.Matrix4.identity()..scale(scale, -scale);
    path = path.transform(tScale.storage);
    boundRect = path.getBounds();
    vm.Matrix4 tTranslate = vm.Matrix4.translation(
      vm.Vector3(_constraints.maxWidth / 2 - boundRect.center.dx,
          _constraints.maxHeight / 2 - boundRect.center.dy, 0),
    );
    path = path.transform(tTranslate.storage);
    return path;
  }
}
