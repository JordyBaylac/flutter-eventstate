import 'package:flutter/material.dart';
import 'package:fttq/fttq.dart';

void main() {
  initAppState()
  .registerStore(MyThingsStore())
  .registerHandler(IncrementCounterHandler());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    fire(CounterInitialized());

    return MaterialApp(
      title: 'Flutter Eventstate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Counter - example'),
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

class MyThingsStore extends Store {
  int counter = 0;
}

class IncrementCounterHandler extends CommandHandler<IncrementCounter> {
  final MyThingsStore store;
  IncrementCounterHandler() : store = getStore<MyThingsStore>();

  handle(IncrementCounter command) {
    store.counter++;
    fire(CounterUpdated(store.counter));
  }
}

class IncrementCounter extends Command {}

class CounterInitialized extends Event {}

class CounterUpdated extends Event {
  final int counter;

  CounterUpdated(this.counter);
}
