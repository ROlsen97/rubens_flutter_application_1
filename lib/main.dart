import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CountdownTimer()
          ],
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  static const platform = MethodChannel('com.example.timer/stopAudio');
  Timer? _timer;
  int _start = 0;
  bool _isRunning = false;

  Future<void> stopAllAudio() async {
    try {
      await platform.invokeMethod('stopAudio');
    } on PlatformException catch (e) {
      print("Failed to stop audio: '${e.message}'.");
    }
  }

  void startTimer() {
    if (_timer != null) {
      _timer?.cancel();
    }
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _isRunning = false;
          _timer?.cancel();
          stopAllAudio();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Time\'s up!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  void stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  void resetTimer() {
    if (_timer != null) {
      _timer?.cancel();
    }
    setState(() {
      _start = 0;
      _isRunning = false;
    });
  }

  void setTime(int hours, int minutes, int seconds) {
    setState(() {
      _start = hours * 3600 + minutes * 60 + seconds;
    });
  }

  void setHours() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text('Set Hours'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter hours"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setTime(int.parse(_controller.text), _minutes(), _seconds());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setMinutes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text('Set Minutes'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter minutes"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setTime(_hours(), int.parse(_controller.text), _seconds());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setSeconds() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text('Set Seconds'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter seconds"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setTime(_hours(), _minutes(), int.parse(_controller.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int _hours() {
    return _start ~/ 3600;
  }

  int _minutes() {
    return (_start % 3600) ~/ 60;
  }

  int _seconds() {
    return _start % 60;
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: setHours,
          child: Text(
            '${_hours().toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 48),
          ),
        ),
        GestureDetector(
          onTap: setMinutes,
          child: Text(
            '${_minutes().toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 48),
          ),
        ),
        GestureDetector(
          onTap: setSeconds,
          child: Text(
            '${_seconds().toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 48),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? stopTimer : startTimer,
              child: Text(_isRunning ? 'Stop' : 'Start'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: resetTimer,
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
