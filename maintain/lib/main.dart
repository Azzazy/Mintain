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
                            MaterialPageRoute(
                                builder: (context) =>
                                    SessionInfo(session: session)),
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
    return Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
           ListTile(
            leading: const Icon(Icons.new_releases),
            title:  Text(job.title),
            subtitle:
                const Text('Work details'),
          ),
          new ButtonTheme.bar(
            // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('APPLY'),
                  onPressed: () {
                    /* ... */
                  },
                ),
                new FlatButton(
                  child: const Text('APPLY AS MENTOR'),
                  onPressed: () {
                    /* ... */
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
//    return GestureDetector(
//        onTap: () {
//          Navigator.push(context,
//              MaterialPageRoute(builder: (context) => WorkInfo(job: job)));
//        },
//        child: Column(
//          children: <Widget>[
//            Row(children: <Widget>[
//              Text(
//                job.title,
//              ),
//              Text(job.deadline.day.toString() +
//                  '/' +
//                  job.deadline.month.toString() +
//                  '/' +
//                  job.deadline.year.toString())
//            ]),
//            Row(
//              children: <Widget>[Text(job.owner.name), Text(job.owner.address)],
//            ),
//            Row(
//              children: <Widget>[
//                Text(job.type),
//                Text(job.duration.toString()),
//                Text(job.salary.toString())
//              ],
//            )
//          ],
//        ));
  }
}
