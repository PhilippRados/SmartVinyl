import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_vinyl_app/main.dart';
import 'package:tuple/tuple.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:lottie/lottie.dart';

class AlbumInfo extends StatefulWidget {
  AlbumInfo({dynamic this.album_data});
  final dynamic album_data;

  @override
  _AlbumInfoState createState() => _AlbumInfoState();
}

class _AlbumInfoState extends State<AlbumInfo> {
  dynamic selectedValue = 0;
  final List<String> record_sides = ["A", "B", "C", "D", "E"];
  List<Tuple3<dynamic, dynamic, dynamic>> current_record_side_list = [];
  int song_index = 0;
  bool loading = false;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
  );

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  void pause_play() {
    if (_stopWatchTimer.isRunning) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    } else {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    }
  }

  void change_timer_value(int song_index) async {
    int new_time = TimerState(
            song_index: song_index,
            record_side: current_side_list(
                record_sides[selectedValue], widget.album_data))
        .get_start_value();

    await _resetTimer();
    _stopWatchTimer.setPresetSecondTime(new_time);
  }

  Future<void> _resetTimer() {
    final completer = Completer<void>();

    // Create a listener that will trigger the completer when
    // it detects a reset event.
    void listener(StopWatchExecute event) {
      if (event == StopWatchExecute.reset) {
        completer.complete();
      }
    }

    // Add the listener to the timer's execution stream, saving
    // the sub for cancellation
    final sub = _stopWatchTimer.execute.listen(listener);

    // Send the 'reset' action
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);

    // Cancel the sub after the future is fulfilled.
    return completer.future.whenComplete(sub.cancel);
  }

  @override
  Widget build(BuildContext context) {
    return (loading == true)
        ? LoadingAnimation()
        : SafeArea(
            child: Container(
              height: 500,
              width: 500,
              color: Color(0xff273A4D),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            widget.album_data.cover,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.grey.withOpacity(0),
                                Color(0xff273A4D).withOpacity(1)
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xffEC3857),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8))),
                          child: IconButton(
                            alignment: Alignment.topLeft,
                            onPressed: () {
                              Navigator.pop(context, '/');
                            },
                            icon: Icon(Icons.chevron_left),
                            iconSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 180),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  widget.album_data.album_name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  widget.album_data.artist,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xffFCF2F5),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: DropdownButton(
                          items: get_record_sides(widget.album_data),
                          value: selectedValue,
                          onChanged: (dynamic value) {
                            setState(() {
                              selectedValue = value;
                              song_index = 0;
                              change_timer_value(song_index);
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 359,
                      child: StreamBuilder<int>(
                          stream: _stopWatchTimer.secondTime,
                          initialData: 0,
                          builder: (context, snap) {
                            final value = snap.data;
                            int end_value = TimerState(
                                    song_index: song_index,
                                    record_side: current_side_list(
                                        record_sides[selectedValue],
                                        widget.album_data))
                                .get_end_value();
                            if (value == end_value - 1) {
                              if (song_index <
                                  record_side_length(
                                          record_sides[selectedValue],
                                          widget.album_data) -
                                      1) {
                                song_index++;
                              } else {
                                pause_play(); //Pause icon doesnt change
                                print("end of record");
                              }
                            }
                            return Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 0),
                                    child: Container(
                                      child: ListView.builder(
                                        itemExtent: 60,
                                        itemCount: record_side_length(
                                            record_sides[selectedValue],
                                            widget.album_data),
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            onTap: () {
                                              if (_stopWatchTimer.isRunning) {
                                                print("cant change");
                                              } else {
                                                setState(() {
                                                  song_index = index;
                                                  change_timer_value(
                                                      song_index);
                                                });
                                              }
                                            },
                                            title: Text(
                                              current_side_list(
                                                      record_sides[
                                                          selectedValue],
                                                      widget.album_data)[index]
                                                  .item1,
                                              style: TextStyle(
                                                  color: (index == song_index)
                                                      ? Colors.white
                                                      : Color(0xffE9EDF1),
                                                  fontSize: 18,
                                                  fontWeight:
                                                      (index == song_index)
                                                          ? FontWeight.w800
                                                          : FontWeight.w400),
                                            ),
                                            trailing: Text(
                                              convert_length_to_mins(
                                                  current_side_list(
                                                          record_sides[
                                                              selectedValue],
                                                          widget
                                                              .album_data)[index]
                                                      .item3),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  letterSpacing: 1.5),
                                            ),
                                          );
                                        },
                                        key: UniqueKey(),
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  height: 55,
                                  width: MediaQuery.of(context).size.width,
                                  curve: Curves.decelerate,
                                  color: Color(0xff0F1821),
                                  alignment: Alignment.bottomCenter,
                                  duration: Duration(milliseconds: 300),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topCenter,
                                        child: Stack(
                                          children: [
                                            LinearProgressIndicator(
                                              backgroundColor: Colors.black54,
                                              color: Color(0xffFC1F60),
                                              value: TimerState(
                                                      current_time_sec: value!,
                                                      song_index: song_index,
                                                      record_side:
                                                          current_side_list(
                                                              record_sides[
                                                                  selectedValue],
                                                              widget
                                                                  .album_data))
                                                  .get_value_progress(),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 18.0, top: 2),
                                                  child: Text(
                                                    current_side_list(
                                                                record_sides[
                                                                    selectedValue],
                                                                widget
                                                                    .album_data)[
                                                            song_index]
                                                        .item1,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: 1.15),
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        if (_stopWatchTimer
                                                                    .isRunning ==
                                                                false &&
                                                            song_index > 0) {
                                                          setState(() {
                                                            song_index--;
                                                            change_timer_value(
                                                                song_index);
                                                            // changeSongRequest(
                                                            //     song_index);
                                                          });
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.skip_previous,
                                                        color: Colors.white,
                                                      )),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        loading = !loading;
                                                      });
                                                      bool success =
                                                          await pausePlayRequest(
                                                              (_stopWatchTimer
                                                                          .isRunning ==
                                                                      true)
                                                                  ? "OFF"
                                                                  : "ON");
                                                      if (success == true) {
                                                        setState(() {
                                                          pause_play();
                                                          loading = !loading;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          loading = !loading;
                                                        });
                                                        AlertDialog(
                                                            semanticLabel:
                                                                "Couldnt send request");
                                                      }
                                                    },
                                                    icon: Icon(
                                                        (_stopWatchTimer
                                                                .isRunning)
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        if (_stopWatchTimer
                                                                    .isRunning ==
                                                                false &&
                                                            song_index <
                                                                record_side_length(
                                                                        record_sides[
                                                                            selectedValue],
                                                                        widget
                                                                            .album_data) -
                                                                    1) {
                                                          setState(() {
                                                            song_index++;
                                                            change_timer_value(
                                                                song_index);
                                                          });
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.skip_next,
                                                        color: Colors.white,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class LoadingAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              margin: EdgeInsets.only(top: 100),
              child: Stack(
                children: [
                  Lottie.asset(
                    'assets/vinyl_loading.json',
                    repeat: true,
                    reverse: false,
                    animate: true,
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(100, 20, 50, 0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Moving record-needle...",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

String convert_length_to_mins(int song_length) {
  String length = ((Duration(milliseconds: song_length).inSeconds) / 60)
      .toStringAsPrecision(3);

  String mins = length.split(".")[0];

  String seconds =
      ((int.parse(length.split(".")[1]) / 100) * 60).round().toInt().toString();

  if (seconds.length == 1) {
    seconds = "0$seconds";
  }

  return "$mins:$seconds";
}

int record_side_length(String record_side, Album album_data) {
  int length = 0;
  for (int i = 0; i < album_data.track_list.length; i++) {
    if (album_data.track_list[i].item2.contains(record_side)) {
      length++;
    }
  }
  return length;
}

List<Tuple3<dynamic, dynamic, dynamic>> current_side_list(
    String record_side, Album album_data) {
  List<Tuple3<dynamic, dynamic, dynamic>> current_list = [];

  for (int i = 0; i < album_data.track_list.length; i++) {
    if (album_data.track_list[i].item2.contains(record_side)) {
      current_list.add(album_data.track_list[i]);
    }
  }
  return current_list;
}

List<DropdownMenuItem> get_record_sides(Album album_data) {
  List<DropdownMenuItem> record_sides_widgets = [];
  List<String> record_sides = [];
  dynamic j = 0;

  for (int i = 0;; i++) {
    try {
      if (record_sides.contains(album_data.track_list[i].item2[0]) == false) {
        record_sides_widgets.add(
          DropdownMenuItem(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(album_data.track_list[i].item2[0] + "-Side"),
              ),
              value: j),
        );
        record_sides.add(album_data.track_list[i].item2[0]);
        j++;
      }
    } catch (e) {
      return record_sides_widgets;
    }
  }
}

class TimerState {
  TimerState({this.current_time_sec, this.song_index, this.record_side});
  dynamic current_time_sec;
  dynamic song_index;
  dynamic record_side;

  int get_start_value() {
    int start = 0;
    for (int i = 0; i < song_index; i++) {
      start += Duration(milliseconds: record_side[i].item3).inSeconds;
    }
    return start;
  }

  int get_end_value() {
    int end = 0;
    end = get_start_value() +
        Duration(milliseconds: record_side[song_index].item3).inSeconds;
    return end;
  }

  double get_value_progress() {
    return (current_time_sec - get_start_value()) /
        (get_end_value() - get_start_value());
  }
}

Future<bool> pausePlayRequest(String change_to) async {
  http.Response json_response = await http
      .get(Uri.http("192.168.0.158", "/", {"arm_status": "$change_to%"}));

  if (json_response.statusCode == 200) {
    return true;
  }
  return false;
}

int convertSongtimeToServoValue(int song_index, dynamic record_side) {
  return 1;
}

Future<bool> changeSongRequest(int song_index, dynamic record_side) async {
  int change_to = convertSongtimeToServoValue(song_index, record_side);
  http.Response json_response = await http
      .get(Uri.http("192.168.0.158", "/", {"needle_value": "$change_to%"}));

  if (json_response.statusCode == 200) {
    return true;
  }
  return false;
}
