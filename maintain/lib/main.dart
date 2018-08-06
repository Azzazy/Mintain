import 'dart:_http';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

const String SERVER_URL = 'http://192.168.43.48:3000';
void main() => runApp(App());

class App extends StatelessWidget {
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

  List<Widget> _children = [
    WorkScreen(jobs: List<Job>.generate(50, (i) => Job("Job No.$i"))),
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
            title: Text('class'),
          ),
          new BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Profile'))
        ],
      ),
    );
  }
}

class WorkScreen extends StatelessWidget {
  final List<Job> jobs;

  WorkScreen({Key key, this.jobs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return WorkItem(
            job: job,
          );
        });
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
      FutureBuilder<Individual>(
          future: fetchIndividual("koko@hot.com", "a7a"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.about);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}" + "${snapshot.toString()}");
            }

            // By default, show a loading spinner
            return CircularProgressIndicator();
          }),
    ]);
  }
}

class WorkInfoScreen extends StatelessWidget {
  final Job job;

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

class Organization {
  String address;
  String website;
  String name;
  String email;
  bool isIndi;
  String about;
  String avatar;

  Organization({this.name, this.email, this.isIndi, this.about, this.avatar, this.website, this.address});

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'],
      email: json['email'],
      isIndi: json['isIndi'],
      about: json['about'],
      avatar: json['avatar'],
      website: json['website'],
      address: json['address'],
    );
  }
}

//Future<Organization> fetchOrganization(email, password) async {
//  final response = await http.get(SERVER_URL + '/login/$email/$password');
//
//  if (response.statusCode == 200) {
//    // If the call to the server was successful, parse the JSON
//    return Organization.fromJson(json.decode(response.body));
//  } else {
//    // If that call was not successful, throw an error.
//    throw Exception('Login failed');
//  }
//}

class Individual {
  String name;
  String email;
  String about;
  String avatar;

  Individual({this.name, this.email, this.about, this.avatar});

  factory Individual.fromJson(Map<String, dynamic> json) {
    return Individual(
      name: json['name'],
      email: json['email'],
      about: json['about'],
      avatar: json['avatar'],
    );
  }
}

Future<String> apiRequest(String url, Map jsonMap) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode({"email": "koko@hot.com", "password": "a7a"})));
  HttpClientResponse response = await request.close();
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return reply;
}

Future<Individual> fetchIndividual(email, password) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(SERVER_URL + '/auth/login'));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode({"email": email, "password": password})));
  HttpClientResponse response = await request.close();
//  final response = await http.post(SERVER_URL + '/auth/login', body: {email: email, password: password});
  print(response.statusCode);
  print(response.toString());
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Individual.fromJson(json.decode(response.toString()));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Login failed');
  }
}

class Job {
  String title;
  DateTime deadline;
  bool paid;
  Organization owner;
  String type;
  String exp;
  int positions;
  String category;
  int salary;
  String description;

  Job(title) {
    this.title = title;
    this.owner = new Organization(name: 'Microsoft', address: 'NYC');
    this.salary = 1000;
    this.description = 'Required a very good person for this job';
    this.deadline = DateTime.now();
    this.type = 'Full time';
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
  final Job job;

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
                    Text(job.deadline.day.toString() + '/' + job.deadline.month.toString() + '/' + job.deadline.year.toString())
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
                            style: TextStyle(fontSize: 18.0, color: Colors.yellow),
                          )),
                    ],
                  )
                ],
              )),
        ));
  }
}
