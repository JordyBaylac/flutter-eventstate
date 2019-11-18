import 'package:flutter/material.dart';

import 'package:fttq/fttq.dart';

import 'examples/login/domain/login/commands.dart';
import 'examples/login/domain/login/events.dart';
import 'examples/login/domain/login/store.dart';

void main() {
  initAppState();
  addStore(AuthStore());
  registerHandler(LoginHandler());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

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
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(20),
              child: StreamBuilder(
                stream: listen<LoginFailed>(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("unexpected error during LoginFailed!!");
                  }
                  if (!snapshot.hasData) {
                    return Text("LoginFailed?? nothing ...");
                  }
                  return Text("LoginFailed, try other email",
                      style: Theme.of(context).textTheme.body1);
                },
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              color: Colors.green,
              padding: EdgeInsets.all(20),
              child: StreamBuilder(
                stream: listen<LoginOk>(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("error receiving LoginOk!!");
                  }
                  if (!snapshot.hasData) {
                    return Text("Touch the USER button ...");
                  }
                  print("Login successful");
                  return Text("Login successful",
                      style: Theme.of(context).textTheme.body1);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          trigger(LoginCmd("admin"));
        },
        tooltip: 'LOGIN',
        child: Icon(Icons.supervised_user_circle),
      ),
    );
  }
}
