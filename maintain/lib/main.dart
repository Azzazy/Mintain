import 'dart:_http';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String SERVER_URL = 'http://192.168.43.48:3000';
void main() => runApp(App());

enum AuthState { LOGGED_IN, LOGGED_OUT }

class App extends StatelessWidget {
  static var ent = new Entity();
  static var auth = AuthState.LOGGED_OUT;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: LoginPage(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  List<Widget> _children = [
//    WorkScreen(jobs: List<Job>.generate(50, (i) => Job("Job No.$i"))),
    WorkScreen(),
    SessionsScreen(sessions: List<Session>.generate(50, (i) => Session("Session No.$i"))),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        }, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.work),
            title: Text('Work'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            title: Text('Sessions'),
          ),
          new BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Profile'))
        ],
      ),
    );
  }
}

class WorkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: new FutureBuilder<List<Work>>(
            future: fetchWork(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else {
                    print("WORK RETIRIVED DONE.");
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          final job = snapshot.data[index];
                          return WorkItem(
                            job: job,
                          );
                        });
                  }
              }
            }));

//    return Column(
//      children: <Widget>[
//        FutureBuilder<List<Work>>(
//            future: fetchWork(),
//            builder: (BuildContext context, AsyncSnapshot snapshot) {
//              if (snapshot.hasData) {
//                if (snapshot.data!=null) {
//                  print(snapshot.data);
//                  Text('ok');
//                } else {
//                  return new CircularProgressIndicator();
//                }
//              }
//            }),
//        Text('Fill space')
//      ],
//    );
  }
}

class SessionsScreen extends StatelessWidget {
  final List<Session> sessions;

  SessionsScreen({Key key, this.sessions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return SessionItem(
            session: session,
          );
        });
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
//      new Container(
//          width: 300.0,
//          height: 300.0,
//          decoration: new BoxDecoration(
//              shape: BoxShape.circle,
//              image: new DecorationImage(
//                  fit: BoxFit.fill,
//                  image: new NetworkImage(
//                      "https://scontent-cai1-1.xx.fbcdn.net/v/t1.0-9/18034115_1272004189584244_372824399076481497_n.jpg?_nc_cat=0&oh=848127cc6ba4c34885bcaf2131fe0b66&oe=5BCCE821")))),
//      FutureBuilder<Individual>(
//          future: login(App.indi),
//          builder: (BuildContext context, AsyncSnapshot snapshot) {
//            switch (snapshot.connectionState) {
//              case ConnectionState.none:
//              case ConnectionState.waiting:
//                return CircularProgressIndicator();
//              default:
//                if (snapshot.hasError)
//                  return new Text('Error: ${snapshot.error}');
//                else
//                  return Text(App.indi.token);
//            }
//          }),
    ]);
  }
}

class WorkInfoScreen extends StatelessWidget {
  final Work job;

  WorkInfoScreen({Key key, this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job.title + 'details'),
      ),
      body: Center(child: Text(job.title)),
    );
  }
}

class SessionInfoScreen extends StatelessWidget {
  final Session session;

  SessionInfoScreen({Key key, this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session.title + ' info'),
      ),
      body: Center(child: Text(session.title)),
    );
  }
}

class Entity {
  String email;
  String password;
  String token;
  String type;
  Entity({this.email, this.password, this.token, this.type});
}

class Organization extends Entity {
  String address;
  String website;
  String name;
  String email;
  bool isIndi;
  String about;
  String avatar;

  Organization({this.name, this.email, this.isIndi, this.about, this.avatar, this.website, this.address});
}

class Individual extends Entity {
  String name;
  String email;
  String about;
  String avatar;

  Individual({this.name, this.email, this.about, this.avatar});
}

void login(context) async {
  HttpClientRequest request = await HttpClient().postUrl(Uri.parse(SERVER_URL + '/auth/login'));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode({"email": App.ent.email, "password": App.ent.password})));
  HttpClientResponse response = await request.close();
  if (response.statusCode == 200) {
    response.transform(utf8.decoder).listen((body) {
      App.ent.token = json.decode(body)['token'];
      App.auth = AuthState.LOGGED_IN;
      fetchEntity().then((ent) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      });
    });
  } else {
    throw Exception('Login failed');
  }
}

Future<Entity> fetchEntity() async {
  final response = await http.get(
    SERVER_URL + '/auth/profile',
    headers: {HttpHeaders.AUTHORIZATION: 'Bearer ' + App.ent.token},
  );
  var data = json.decode(response.body);
  var type = data['type'];
  if (type == 'ind') {
    var ind = Individual(email: App.ent.email);
    ind.token = App.ent.token;
    return null;
  } else {
    var org = Organization(email: App.ent.email);
    org.token = App.ent.token;
    return null;
  }
}

Future<List<Work>> fetchWork() async {
  final response = await http.get(
    SERVER_URL + '/auth/worklist',
    headers: {HttpHeaders.AUTHORIZATION: 'Bearer ' + App.ent.token},
  );
  Map data = json.decode(response.body);
  List elements = new List();
  elements.addAll(data.values);
  List<Work> works = new List<Work>();
  elements.forEach((e) {
    works.add(Work.fromJson(e));
  });
  return works;
}

class Work {
  String title;
  String postDate;
  String paid;
  Organization owner;
  String type;
  String exp;
  String salary;
  String description;
  String id;
  String vac;

  Work({this.title, this.owner, this.salary, this.description, this.type, this.paid, this.exp, this.id, this.postDate, this.vac});

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      title: json['title'].toString(),
      id: json['_id'].toString(),
      type: json['jobType'].toString(),
      description: json['description'].toString(),
      salary: json['salary'].toString(),
      postDate: json['postDate'].toString(),
      paid: json['paid'].toString(),
      vac: json['vac'].toString(),
      owner: Organization(name: json['company']['name'].toString(), address: json['company']['address'].toString()),
    );
  }
}

class Session {
  String title;
  Individual instructor;
  String details;

  Session(title) {
    this.title = title;
    this.instructor = Individual(name: 'khaled');
    this.details = 'The best ever course you\'ll take in your life';
  }
}

class WorkItem extends StatelessWidget {
  final Work job;

  WorkItem({Key key, this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkInfoScreen(job: job)));
        },
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    Padding(
                        padding: new EdgeInsets.all(10.0),
                        child: Text(
                          job.title,
                          style: TextStyle(fontSize: 24.0),
                        )),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
                        child: Text(
                          job.owner.name,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Text(', ' + job.owner.address)
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                          child: Text(
                            job.type,
                            style: TextStyle(fontSize: 18.0, color: Colors.yellow),
                          )),
                      Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                          child: Text(
                            job.salary.toString(),
                            style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                          )),
                    ],
                  )
                ],
              )),
        ));
  }
}

class SessionItem extends StatelessWidget {
  final Session session;

  SessionItem({Key key, this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SessionInfoScreen(session: session)));
        },
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    Padding(
                        padding: new EdgeInsets.all(10.0),
                        child: Text(
                          session.title,
                          style: TextStyle(fontSize: 24.0),
                        )),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
                        child: Text(
                          session.instructor.name,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                          child: Text(
                            'Place holder', //job.type,
                            style: TextStyle(fontSize: 18.0, color: Colors.green),
                          )),
                    ],
                  )
                ],
              )),
        ));
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    if (App.auth == AuthState.LOGGED_IN) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
    final emailText = TextEditingController();
    final passwordText = TextEditingController();

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    var email = TextFormField(
        controller: emailText,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ));

    final password = TextFormField(
      controller: passwordText,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
            App.ent.password = passwordText.text;
            App.ent.email = emailText.text;
            login(context);
          },
          color: Colors.lightBlueAccent,
          child: Text('Log In', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[logo, SizedBox(height: 48.0), email, SizedBox(height: 8.0), password, SizedBox(height: 24.0), loginButton, forgotLabel],
        ),
      ),
    );
  }
}
