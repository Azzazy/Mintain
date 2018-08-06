import 'package:flutter/material.dart';

void main() {
  runApp(MainScreen(
    jobs: List<Job>.generate(
      50,
      (i) => Job("Job No. $i"),
    ),
    sessions: List<Session>.generate(
      50,
      (i) => Session("Session No. $i"),
    ),
  ));
}

class MainScreen extends StatelessWidget {
  final List<Job> jobs;
  final List<Session> sessions;

  MainScreen({Key key, this.jobs, this.sessions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.work)),
                Tab(icon: Icon(Icons.class_)),
                Tab(icon: Icon(Icons.person)),
              ],
            ),
            title: Text('Mintain'),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return WorkItem(
                      job: job,
                    );
                  }),
              ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SessionInfo(session: session)),
                          );
                        },
                        title: Text(
                          session.title,
                          style: Theme.of(context).textTheme.headline,
                        ),
                        subtitle: ListTile(
                          title: Text(
                            session.instructor.name,
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          subtitle: Text(session.details),
                        ));
                  }),
              Icon(Icons.person),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkInfo extends StatelessWidget {
  final Job job;

  WorkInfo({Key key, this.job}) : super(key: key);

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

class SessionInfo extends StatelessWidget {
  final Session session;

  SessionInfo({Key key, this.session}) : super(key: key);

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
  String email;
  String website;
  String name;
  String about;
  String address;

  Organization(name, address) {
    this.name = name;
    this.address = address;
  }
}

class Job {
  String title;
  Organization owner;
  int salary;
  String details;
  int duration;
  DateTime deadline;
  String type;

  Job(title) {
    this.title = title;
    this.owner = new Organization('Microsoft', 'NYC');
    this.salary = 1000;
    this.details = 'Required a very good person for this job';
    this.duration = 15;
    this.deadline = DateTime.now();
    this.type = 'Full time';
  }
}

class Individual {
  String name;
  String email;
  String bio;

  Individual() {
    this.name = "Khaled";
  }
}

class Session {
  String title;
  Individual instructor;
  String details;

  Session(title) {
    this.title = title;
    this.instructor = Individual();
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkInfo(job: job)));
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
                            job.duration.toString(),
                            style: TextStyle(fontSize: 18.0, color: Colors.blueAccent),
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
