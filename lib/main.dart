import 'dart:_http';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String SERVER_URL = 'http://192.168.8.102:3000';
const String DEBUG_PASSWORD = 'test';
const String DEBUG_EMAIL = 'test@test.com';

void main() => runApp(App());

enum AuthState { LOGGED_IN, LOGGED_OUT }

class App extends StatelessWidget {
  static var ent = new Entity();
  static var auth = AuthState.LOGGED_OUT;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: Home(),
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

  List<Widget> _children = [WorkScreen(), SessionsScreen(sessions: List<Session>.generate(50, (i) => Session("Session No.$i"))), ProfileScreen()];

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
            future: fetchWork(context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else {
                    print("Work list fetching DONE.");
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
    return Padding(
        padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Row(
            children: <Widget>[
              new Container(
                  width: 96.0,
                  height: 96.0,
                  decoration: new BoxDecoration(shape: BoxShape.circle, image: new DecorationImage(fit: BoxFit.fill, image: new NetworkImage(App.ent.asIndi().picture)))),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    App.ent.asIndi().email,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                  )),
            ],
          ),
          ListTile(
            title: Text(
              'Education',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[Text('High School'), Text('Bachelor'), Text('Masters')],
            ),
          ),
        ]));
  }
}

class WorkInfoScreen extends StatelessWidget {
  final Work work;

  WorkInfoScreen({Key key, this.work}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            backgroundColor: Colors.green,
            child: Text('Apply'),
            onPressed: (){
              Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('You applied for this work.')));

            },
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(work.title),
        actions: <Widget>[
          Center(
            child: Builder(
              builder: (context) {
                return FlatButton(
                    onPressed: () {
                      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('You are now a mentor to this work.')));
                    },
                    child: Text(
                      "Apply as mentor",
                      style: TextStyle(color: Colors.amber, fontSize: 15.0, fontWeight: FontWeight.bold),
                    ));
              },
            ),
          ),
        ],
      ),
      body: new FutureBuilder<Work>(
          future: fetchOneWork(work),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else {
                  print("Work fetching DONE.");

                  return WorkPage(work: work);
                }
            }
          }),
    );
  }
}

class WorkPage extends StatelessWidget {
  Work work;
  WorkPage({Key key, this.work}) : super(key: key);

  /*
  String title;
  Organization owner;
  String postDate;
  String type;
  String salary;
  String vac;
  String paid;
  String description;

  String id;
   */
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text(
                      work.owner.name + ',',
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                    )),
                Padding(
                  padding: EdgeInsets.all(2.5),
                  child: Text(
                    work.owner.address,
                    style: TextStyle(fontSize: 18.0),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  Container(
                      color: Color(0xffFFEFEF),
                      child: ListTile(
                        title: Text('Posted on'),
                        subtitle: Text(work.postDate),
                      )),
                  Container(
                      color: Color(0xffFFF8EF),
                      child: ListTile(
                        title: Text('Type'),
                        subtitle: Text(work.type),
                      )),
                  Container(
                      color: Color(0xffFAFFEF),
                      child: ListTile(
                        title: Text('Salary'),
                        subtitle: Text(work.salary),
                      )),
                  Container(
                      color: Color(0xffF5FFEF),
                      child: ListTile(
                        title: Text('Paid'),
                        subtitle: Text(work.paid),
                      )),
                  Container(
                      color: Color(0xffEFFFF7),
                      child: ListTile(
                        title: Text('# vacant positions'),
                        subtitle: Text(work.vac),
                      )),
                  Container(
                      color: Color(0xffF6F6F6),
                      child: ListTile(
                        title: Text('Details'),
                        subtitle: Text(work.description),
                      )),
//            ListTile(
//              title: Text('Experiance needed'),
//              subtitle: Text(work.exp),
//            ),
                ],
              ),
            )
          ],
        ));
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

  Individual asIndi() {
    return null;
  }
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
  String mobile;
  String email;
  List<String> edu;
  List<String> skills;
  List<String> exp;
  List<String> languages;
  String cv;
  String about;
  String picture;
  String id;

  Individual({this.name, this.email, this.about, this.picture});

  @override
  Individual asIndi() {
    return this;
  }
}

Future<Entity> login(context) async {
  HttpClientRequest request = await HttpClient().postUrl(Uri.parse(SERVER_URL + '/auth/login'));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode({"email": App.ent.email, "password": App.ent.password})));
  HttpClientResponse response = await request.close();
  if (response.statusCode == 200) {
    response.transform(utf8.decoder).listen((body) async {
      App.ent.token = json.decode(body)['token'];
      App.auth = AuthState.LOGGED_IN;
      await fetchEntity();
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
    var ind = Individual(email: App.ent.email, name: data['name'], picture: data['picture']);
    ind.token = App.ent.token;

    App.ent = ind;
    return null;
  } else {
    var org = Organization(email: App.ent.email);
    org.token = App.ent.token;
    App.ent = org;
    return null;
  }
}

Future<List<Work>> fetchWork(context) async {
  List<Work> works = new List<Work>();

  App.ent.password = DEBUG_PASSWORD;
  App.ent.email = DEBUG_EMAIL;
  await login(context).then((ent) async {
    var response = await http.get(
      SERVER_URL + '/auth/worklist',
      headers: {HttpHeaders.AUTHORIZATION: 'Bearer ' + App.ent.token},
    );
    Map data = json.decode(response.body);
    List elements = new List();
    elements.addAll(data.values);
    elements.forEach((e) {
      works.add(Work.fromJson(e));
    });
  });
  return works;
}

Future<Work> fetchOneWork(Work work) async {
  var response = await http.get(
    SERVER_URL + '/auth/work/' + work.id,
    headers: {HttpHeaders.AUTHORIZATION: 'Bearer ' + App.ent.token},
  );
  Map data = json.decode(response.body);
  print(data);
  return Work.fromJson(data);
}

class Work {
  String title;
  String postDate;
  String paid;
  Organization owner;
  String type;
  String salary;
  String description;
  String id;
  String vac;

  Work({this.title, this.owner, this.salary, this.description, this.type, this.paid, this.id, this.postDate, this.vac});

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkInfoScreen(work: job)));
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
