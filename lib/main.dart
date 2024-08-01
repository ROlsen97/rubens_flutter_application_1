import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
            // BigCard(pair: pair),
            // SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: () {
            //     appState.getNext();
            //   },
            //   child: Text('Next'),
            // ),
            // SizedBox(height: 20),
            CountdownTimer()
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  int _start = 0;
  bool _isRunning = false;

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
