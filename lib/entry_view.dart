import 'package:flutter/material.dart';
import 'entry.dart';
import 'gps_trip.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.title});
  final String title;
  @override
  State<EntryView> createState() => _EntryView();
}

class _EntryView extends State<EntryView> {
  ValueNotifier<List<Entry>> entryLog = ValueNotifier<List<Entry>>([]);
  GPSTrip gpsTrip = GPSTrip();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add this line


  void _AddEntry() async {
    DateTime? start;
    DateTime? end;
    int? mileage;
    List<String> taglist = <String>[];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Entry'),
          content: Column(
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (date){
                          start = date;
                        });
                  },
                  child: const Text(
                    "Select start time",
                    style: TextStyle(color: Colors.blue),
                  )
              ),
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (date){
                          end = date;
                        });
                  },
                  child: const Text(
                    "Select end time",
                    style: TextStyle(color: Colors.blue),
                  )
              ),
              TextField(
                onChanged: (value) { mileage = int.parse(value); },
                decoration: InputDecoration(hintText: "Enter mileage"),
              ),
              TextField(
                onChanged: (value) {
                  String n = value;
                  taglist = n.split(' ');
                },
                decoration: InputDecoration(hintText: "Enter tags (Optional)"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (start != null && end != null && mileage != null) {
                  // Create a new Entry object using the parsed start time, end time, and mileage
                  Entry temp = Entry(start!, end!, mileage!);
                  temp.retag(taglist);
                  // Create a new list that includes the new Entry
                  List<Entry> newList = List.from(entryLog.value)..add(temp);
                  // Assign the new list to the ValueNotifier
                  entryLog.value = newList;
                  // Print the entryLog to the console for debugging
                  print(entryLog.value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _EditEntry(Entry entry, int index) async {
    DateTime? start = entry.start;
    DateTime? end = entry.end;
    int? mileage = entry.mileage;
    List<String> taglist = entry.getTags();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Entry'),
          content: Column(
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (date){
                          start = date;
                        });
                  },
                  child: const Text(
                    "Select start time",
                    style: TextStyle(color: Colors.blue),
                  )
              ),
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (date){
                          end = date;
                        });
                  },
                  child: const Text(
                    "Select end time",
                    style: TextStyle(color: Colors.blue),
                  )
              ),
              TextField(
                onChanged: (value) { mileage = int.parse(value); },
                decoration: InputDecoration(hintText: "Enter mileage"),
              ),
              TextField(
                onChanged: (value) {
                  String n = value;
                  taglist = n.split(' ');
                },
                decoration: InputDecoration(hintText: "Enter tags (Optional)"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                if (start != null && end != null && mileage != null) {
                  // Update the Entry object with the new values
                  entry.start = start!;
                  entry.end = end!;
                  entry.mileage = mileage!;
                  entry.retag(taglist);

                  // Create a new list from the existing entryLog.value
                  List<Entry> newList = List.from(entryLog.value);
                  // Replace the entry at the given index with the updated entry
                  newList[index] = entry;
                  // Assign the new list to entryLog.value
                  entryLog.value = newList;

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: entryLog,
              builder: (BuildContext context, List<Entry> value, Widget? child) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.local_taxi),
                      title: Text(value[index].toString()),
                      onTap: () => _EditEntry(value[index], index),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              PermissionStatus status = await gpsTrip.startTrip();
              if (!status.isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location permission is not granted')),
                );
              } else {
                await gpsTrip.trackLocation();
              }
            },
            child: Text('Start Trip'),
          ),
          ElevatedButton(
            onPressed: () async {
              await gpsTrip.endTrip();
              Entry entry = gpsTrip.getEntry();
              entryLog.value = List.from(entryLog.value)..add(entry);
            },
            child: Text('End Trip'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _AddEntry,
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}