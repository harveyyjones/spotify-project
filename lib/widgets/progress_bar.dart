import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';

class MusicProgressBar extends StatefulWidget {
  Duration totalDuration;
  Duration playBackPosition;

  MusicProgressBar(
      {Key? key, required this.totalDuration, required this.playBackPosition})
      : super(key: key);

  @override
  _MusicProgressBarState createState() => _MusicProgressBarState();
}

class _MusicProgressBarState extends State<MusicProgressBar> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = 0.0;
    startProgressBar();
  }

  void startProgressBar() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
      } else {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      child: Stack(
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
