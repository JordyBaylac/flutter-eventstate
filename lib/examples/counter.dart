import 'package:flutter/material.dart';
import 'package:fttq/fttq.dart';

void main() {
  registerHandler(IncrementCounterHandler());
  registerHandler(DecrementCounterHandler());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    fire(CounterInitialized());

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder(
              stream: listen<CounterInitialized>(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("error receiving CounterInitialized!!");
                }
                if (!snapshot.hasData) {
                  return Text("Initializing ...");
                }
                return Text("Counter has been initialized",
                    style: Theme.of(context).textTheme.body1);
              },
            ),
            SizedBox(
              height: 40,
            ),
            StreamBuilder(
              stream: listen<CounterUpdated>(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("error receiving CounterUpdated!!");
                }
                if (!snapshot.hasData) {
                  return Text("Touch the + button ...");
                }
                var eventInfo = snapshot.data as CounterUpdated;
                print("CounterUpdated handled, data is ${eventInfo.counter}");
                return Text("${eventInfo.counter}",
                    style: Theme.of(context).textTheme.body1);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          trigger(IncrementCounter());
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

int counter = 0;

class IncrementCounterHandler extends CommandHandler<IncrementCounter> {
  handle(IncrementCounter command) {
    counter++;
    fire(CounterUpdated(counter));
  }
}

class DecrementCounterHandler extends CommandHandler<DecrementCounter> {
  handle(DecrementCounter command) {
    counter--;
    fire(CounterUpdated(counter));
  }
}

class IncrementCounter extends Command {}

class DecrementCounter extends Command {}

class CounterInitialized extends Event {}

class CounterUpdated extends Event {
  final int counter;

  CounterUpdated(this.counter);
}
