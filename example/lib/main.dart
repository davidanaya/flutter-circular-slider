import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_circular_slider/flutter_circular_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background_morning.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SleepPage()),
    ));
  }
}

class SleepPage extends StatefulWidget {
  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final baseColor = Color.fromRGBO(255, 255, 255, 0.3);

  int _initTime;
  int _endTime;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    setState(() {
      _initTime = _generateRandomTime();
      _endTime = _generateRandomTime();
    });
  }

  void _updateTime(int initTime, int endTime) {
    setState(() {
      _initTime = initTime;
      _endTime = endTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'How long did you stay in bed?',
          style: TextStyle(color: Colors.white),
        ),
        CircularSlider(
          288,
          _initTime,
          _endTime,
          height: 220.0,
          width: 220.0,
          baseColor: Color.fromRGBO(255, 255, 255, 0.1),
          selectionColor: baseColor,
          handlerColor: Colors.white,
          textColor: Colors.white,
          handlerOutterRadius: 12.0,
          onSelectionChange: _updateTime,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
                child: Text('${_formatIntervalTime(_initTime, _endTime)}',
                    style: TextStyle(fontSize: 36.0, color: Colors.white))),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _formatBedTime('IN THE', _initTime),
          _formatBedTime('OUT OF', _endTime),
        ]),
        FlatButton(
          child: Text('S H U F F L E'),
          color: baseColor,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          onPressed: _shuffle,
        ),
      ],
    );
  }

  Widget _formatBedTime(String pre, int time) {
    return Column(
      children: [
        Text(pre, style: TextStyle(color: baseColor)),
        Text('BED AT', style: TextStyle(color: baseColor)),
        Text(
          '${_formatTime(time)}',
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }

  String _formatTime(int time) {
    if (time == 0 || time == null) {
      return '00:00';
    }
    var hours = time ~/ 12;
    var minutes = (time % 12) * 5;
    return '$hours:$minutes';
  }

  String _formatIntervalTime(int init, int end) {
    var sleepTime = end > init ? end - init : 288 - init + end;
    var hours = sleepTime ~/ 12;
    var minutes = (sleepTime % 12) * 5;
    return '${hours}h${minutes}m';
  }

  int _generateRandomTime() => Random().nextInt(288);
}
