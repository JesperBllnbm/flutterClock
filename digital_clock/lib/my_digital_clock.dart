// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/constants/app_colors.dart';
import 'package:digital_clock/path_builder.dart';
import 'package:digital_clock/square_paint.dart';
import 'package:digital_clock/squares_manager.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';

/// A basic digital clock.
///
/// You can do better than this!
/// I tried.
class MyDigitalClock extends StatefulWidget {
  const MyDigitalClock(
      this.clockModel, this.pathBuilder, this.squaresManager, this.constraints);

  final ClockModel clockModel;
  final PathBuilder pathBuilder;
  final SquaresManager squaresManager;
  final BoxConstraints constraints;

  @override
  _MyDigitalClockState createState() => _MyDigitalClockState();
}

class _MyDigitalClockState extends State<MyDigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer, _clockFaceTimer;
  List<Color> _colorPalette = lightThemeColors[0];
  Brightness _brightness = Brightness.light;

  @override
  void initState() {
    super.initState();
    widget.clockModel.addListener(_updateModel);
    _selectColorPaletteForWeather(widget.clockModel.weatherCondition);
    _updateTime();
    _updateClockFace();
    _updateModel();
  }

  @override
  void didUpdateWidget(MyDigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clockModel != oldWidget.clockModel) {
      oldWidget.clockModel.removeListener(_updateModel);
      widget.clockModel.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clockFaceTimer?.cancel();
    widget.clockModel.removeListener(_updateModel);
    widget.clockModel.dispose();
    super.dispose();
  }

  void _updateModel() async {
    if (widget.clockModel.is24HourFormat != widget.pathBuilder.is24HourFormat) {
      await widget.pathBuilder
          .set24HourFormat(widget.clockModel.is24HourFormat);
      widget.squaresManager.reloadTime();
    }
    _selectColorPaletteForWeather(widget.clockModel.weatherCondition);
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateClockFace() {
    _clockFaceTimer = Timer(
      Duration(milliseconds: 17),
      _updateClockFace,
    );
    if (!widget.squaresManager.watchFaceComplete) {
      widget.squaresManager.markForSplit(
          widget.pathBuilder.currentPath, widget.pathBuilder.currentPieces);
      widget.squaresManager.updateSplit();
      widget.squaresManager.cleanUp();
      //I tried to implement with NotifyListeners but it is way slower and flickers.
      setState(() {});
    }
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      //  Update once per second, but make sure to do it at the beginning of each
      //  new second, so that the clock is accurate.
//      _timer = Timer(
//        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
    });
    widget.pathBuilder.dateTime = _dateTime;
    widget.squaresManager.reloadTime();
  }

  void _selectColorPaletteForWeather(WeatherCondition weatherCondition) {
    switch (weatherCondition) {
      case WeatherCondition.cloudy:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[0]
            : darkThemeColors[0];
        break;
      case WeatherCondition.foggy:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[1]
            : darkThemeColors[1];
        break;
      case WeatherCondition.rainy:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[2]
            : darkThemeColors[2];
        break;
      case WeatherCondition.snowy:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[3]
            : darkThemeColors[3];
        break;
      case WeatherCondition.sunny:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[4]
            : darkThemeColors[4];
        break;
      case WeatherCondition.thunderstorm:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[5]
            : darkThemeColors[5];
        break;
      case WeatherCondition.windy:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[6]
            : darkThemeColors[6];
        break;
      default:
        _colorPalette = _brightness == Brightness.light
            ? lightThemeColors[0]
            : darkThemeColors[0];
    }
    widget.squaresManager.colors = _colorPalette;
  }

  @override
  Widget build(BuildContext context) {
    if (_brightness != Theme.of(context).brightness) {
      _brightness = Theme.of(context).brightness;
      _selectColorPaletteForWeather(widget.clockModel.weatherCondition);
    }

    return Container(
        height: widget.constraints.maxHeight,
        width: widget.constraints.maxWidth,
        color: _colorPalette[0],
        child:
            CustomPaint(painter: SquarePaint(widget.squaresManager.squares)));
  }
}
