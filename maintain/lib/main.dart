import 'package:flutter/material.dart';

void main() {
  runApp(MainScreen(
    jobs: List<Job>.generate(
      50,
      (i) => Job("Job No. $i"),
    ),
  ));
}

class MainScreen extends StatelessWidget {
  final List<Job> jobs;

  MainScreen({Key key, this.jobs}) : super(key: key);

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
                  // Let the ListView know how many items it needs to build
                  itemCount: jobs.length,
                  // Provide a builder function. This is where the magic happens! We'll
                  // convert each item into a Widget based on the type of item it is.
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkInfo(job: job)),
                          );
                        },
                        title: Text(
                              job.title +
                                  ', ' +
                                  job.deadline.day.toString() +
                                  '/' +
                                  job.deadline.month.toString() +
                                  '/' +
                                  job.deadline.year.toString(),
                              style: Theme.of(context).textTheme.headline,
                            ) ,
                        subtitle: ListTile(
                          title: Text(
                            job.owner.name + ', ' + job.owner.address,
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          subtitle: Text(job.type +
                              ', ' +
                              job.duration.toString() +
                              ', ' +
                              job.salary.toString()),
                        ));
                  }),
              ListView(
                children: <Widget>[
                  ListTile(
                    title: Text('Backend developer, unpaid'),
                    subtitle: Text('Full time, 0-4 years, Computer software'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkInfo()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_album),
                    title: Text('Album'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Phone'),
                  ),
                ],
              ),
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
        title: Text("Second Screen"),
      ),
      body: Center(child: Text(job.title)),
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
