import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:popup_card/popup_card.dart';
import 'album.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tuple/tuple.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => MyApp(),
      '/album': (context) => AlbumInfo(),
    },
  ));
}

List<Album> records = [];

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<_PopUpItemBodyState> _key = GlobalKey();

  @override
  void initState() {
    //load records data
    super.initState();
    () async {
      await loadRecords();
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff1D2732),
        body: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Your Records",
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xffF6F8F8)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListView.builder(
                      itemExtent: 75,
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            print(records[index].track_list);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             AlbumInfo(album_data: records[index])));
                          },
                          title: Text(
                            records[index].album_name,
                            style: TextStyle(
                                color: Color(0xffE9EDF1),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(records[index].artist,
                              style: TextStyle(
                                color: Color(0xffE9EDF1),
                                fontSize: 12,
                              )),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                            child: Image.network(records[index].cover,
                                fit: BoxFit.cover, width: 75, height: 75),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                records.removeAt(index);
                              });
                              saveRecords(records);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                      key: UniqueKey(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: PopupItemLauncher(
          child: Container(
            color: Color(0xffDC4250),
            width: 60,
            height: 60,
            child: Icon(
              Icons.library_add,
              color: Colors.white,
              size: 26,
            ),
          ),
          tag: "test",
          popUp: PopUpItem(
            child: PopUpItemBody(
              key: _key,
              notify_parent: refresh,
            ),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tag: "test",
            elevation: 2,
            padding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  refresh() {
    setState(() {
      records = records;
    });
  }
}

class Album {
  const Album(
      {required this.cover,
      required this.album_name,
      required this.artist,
      required this.mbid,
      required this.track_list});

  final String cover;
  final String album_name;
  final String artist;
  final String mbid;
  final List<Tuple3<dynamic, dynamic, dynamic>> track_list;

  Map toJson() => {
        "cover": cover,
        "album_name": album_name,
        "artist": artist,
        "mbid": mbid,
        "track_list": "[${trackListToJson(track_list)}]"
      };
}

class PopUpItemBody extends StatefulWidget {
  final Function() notify_parent;
  PopUpItemBody({required Key key, required Function() this.notify_parent})
      : super(key: key);

  @override
  _PopUpItemBodyState createState() => _PopUpItemBodyState();
}

class _PopUpItemBodyState extends State<PopUpItemBody> {
  final _searchController = TextEditingController();
  String search_query = "";
  List<Tuple3<dynamic, dynamic, dynamic>> list_view_albums = [];
  bool empty = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      color: Colors.white,
      height: 550,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_downward)),
          Row(
            children: [
              Container(
                width: 255,
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    search_query = query;
                  },
                  decoration: InputDecoration(
                    hintText: "Artist:Album",
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {
                    list_view_albums.clear();
                    loading = !loading;
                  });
                  List<String> cover_list = [];
                  List<List<Tuple3<dynamic, dynamic, dynamic>>> track_list = [];

                  List<dynamic> responded_albums =
                      await musicBrainzRequest(search_query);

                  for (int i = 0; i < responded_albums.length; i++) {
                    dynamic cover =
                        await coverRequest(responded_albums[i]["id"]);

                    track_list
                        .add(await trackListRequest(responded_albums[i]["id"]));

                    if (cover != null) {
                      cover_list.add(cover);
                    } else {
                      cover_list.add(
                          "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.mm.bing.net%2Fth%3Fid%3DOIP.dcLjdUq0P5z9MgVUDQgMSgHaHa%26pid%3DApi&f=1");
                    }
                  }

                  setState(() {
                    loading = !loading;
                    if (responded_albums.length != 0) {
                      empty = false;
                      for (int i = 0; i < responded_albums.length; i++) {
                        list_view_albums.add(Tuple3(
                            responded_albums[i], cover_list[i], track_list[i]));
                      }
                    } else {
                      empty = true;
                    }
                  });
                },
                icon: Icon(
                  Icons.search,
                  size: 30,
                ),
              )
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 450,
            child: empty
                ? Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Nothing found",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : loading
                    ? LoadingAnimation()
                    : Container(
                        height: 300,
                        child: ListView.builder(
                            itemExtent: 80,
                            itemCount: list_view_albums.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Container(
                                  width: 70,
                                  height: 70,
                                  child: Image.network(
                                    list_view_albums[index].item2,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                title: Text(
                                  list_view_albums[index].item1["release-group"]
                                      ["title"],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
                                ),
                                subtitle: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 3),
                                      child: Text(
                                        list_view_albums[index]
                                            .item1["artist-credit"][0]["name"],
                                        style: TextStyle(
                                          color:
                                              Colors.black, //Color(0xff35393D),
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 3),
                                      height: 10,
                                      child: VerticalDivider(
                                        width: 6,
                                        color: Colors.black,
                                        thickness: 1.2,
                                      ),
                                    ),
                                    Text(
                                      list_view_albums[index]
                                              .item3
                                              .length
                                              .toString() +
                                          " Songs",
                                      style: TextStyle(
                                        color:
                                            Colors.black, //Color(0xff35393D),
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      records.add(
                                        Album(
                                            artist: list_view_albums[index]
                                                    .item1["artist-credit"][0]
                                                ["name"],
                                            album_name: list_view_albums[index]
                                                    .item1["release-group"]
                                                ["title"],
                                            mbid: list_view_albums[index]
                                                .item1["id"],
                                            cover:
                                                list_view_albums[index].item2,
                                            track_list:
                                                list_view_albums[index].item3),
                                      );
                                    });
                                    saveRecords(records);
                                    widget.notify_parent();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Color(0xff35393D),
                                    size: 24,
                                  ),
                                ),
                              );
                            }),
                      ),
          ),
        ],
      ),
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 10,
        height: 10,
        child: Lottie.asset(
          'assets/loading.json',
          repeat: true,
          reverse: false,
          animate: true,
        ));
  }
}

Future trackListRequest(String mbid) async {
  List<Tuple3<dynamic, dynamic, dynamic>> track_list = [];
  dynamic song_name;
  dynamic song_pos;
  dynamic song_length;

  http.Response json_response = await http.get(Uri.parse(
      "http://musicbrainz.org/ws/2/release/$mbid?inc=recordings&fmt=json"));

  if (json_response.statusCode == 200) {
    final decoded_json = json.decode(json_response.body);

    for (int j = 0;; j++) {
      try {
        decoded_json["media"][j];
      } catch (e) {
        break;
      }
      for (int i = 0;; i++) {
        try {
          song_name = decoded_json["media"][j]["tracks"][i]["title"];
          song_pos = decoded_json["media"][j]["tracks"][i]["number"];
          song_length =
              decoded_json["media"][0]["tracks"][i]["recording"]["length"];

          print(song_name);
        } catch (e) {
          break;
        }
        track_list.add(Tuple3<dynamic, dynamic, dynamic>(
            song_name, song_pos, song_length));
      }
    }
  } else {
    print("TrackList connection failed");
  }
  return track_list;
}

Future coverRequest(String mbid) async {
  print(mbid);
  dynamic image_url;
  http.Response json_response = await http
      .get(Uri.parse("http://coverartarchive.org/release/$mbid?fmt=json"));

  if (json_response.statusCode == 200) {
    final decoded_json = json.decode(json_response.body);
    image_url = decoded_json["images"][0]["image"];
  } else {
    print("Failed to connect to Cover-api");
    image_url = null;
  }
  return image_url;
}

Future musicBrainzRequest(String search_query) async {
  List<dynamic> responded_albums = [];
  List<String> info_query = search_query.split(":");
  String artist_name = info_query[0].replaceAll(" ", "%20");
  String album_name = info_query[1].replaceAll(" ", "%20");

  http.Response json_response = await http.get(Uri.parse(
      "https://musicbrainz.org/ws/2/release?query=title%3A%22$album_name%22%20AND%20artist%3A%22$artist_name%22%20AND%20(format%3A%227%5C%22%20vinyl%22%20OR%20format%3A%2210%5C%22%20vinyl%22%20OR%20format%3A%2212%5C%22%20vinyl%22)&fmt=json"));

  if (json_response.statusCode == 200) {
    final decoded_response = json.decode(json_response.body);
    final response_len = decoded_response["releases"].length;

    for (int i = 0; i < response_len; i++) {
      if (decoded_response["releases"][i]["media"][0]["format"] != null &&
          decoded_response["releases"][i]["media"][0]["format"]
              .contains("Vinyl") &&
          decoded_response["releases"][i]["release-group"]["primary-type"] ==
              "Album") {
        responded_albums.add(decoded_response["releases"][i]);
        print(decoded_response["releases"][i]["media"][0]["format"]);
      }
    }
  } else {
    print("Failed to connect to album-api");
  }
  return responded_albums;
}

saveRecords(List<Album> records) async {
  List<dynamic> json_data = [];

  for (int i = 0; i < records.length; i++) {
    json_data.add(records[i].toJson());
  }

  final file = await _localFile;

  file.writeAsString(jsonEncode(json_data));
  print(json_data);
}

loadRecords() async {
  print("load records");
  records.clear();
  try {
    final file = await _localFile;
    final contents = await file.readAsString();
    String cover;
    String artist;
    String album_name;
    String mbid;
    List<Tuple3<dynamic, dynamic, dynamic>> track_list = [];

    dynamic record_string = json.decode(contents);

    for (int record = 0; record < record_string.length; record++) {
      track_list.clear();
      cover = record_string[record]["cover"];
      artist = record_string[record]["artist"];
      album_name = record_string[record]["album_name"];
      mbid = record_string[record]["mbid"];

      for (int i = 0;
          i < jsonDecode(record_string[record]["track_list"]).length;
          i++) {
        Song current_song =
            Song.fromJson(jsonDecode(record_string[record]["track_list"])[i]);
        track_list.add(Tuple3(current_song.song_name, current_song.record_side,
            current_song.song_length));
      }
      records.add(Album(
          cover: cover,
          album_name: album_name,
          artist: artist,
          mbid: mbid,
          track_list: track_list));
    }
  } catch (e) {
    print(e);
  }
  print(records);
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/json_records.json');
}

String trackListToJson(List<Tuple3<dynamic, dynamic, dynamic>> track_list) {
  String trackString = '';

  for (int i = 0; i < track_list.length; i++) {
    String song_name = track_list[i].item1;
    String record_side = track_list[i].item2;
    int song_length = track_list[i].item3;
    if (i == (track_list.length - 1)) {
      trackString = trackString +
          '{"song_name":"$song_name","record_side":"$record_side","song_length":$song_length}';
    } else {
      trackString = trackString +
          '{"song_name":"$song_name","record_side":"$record_side","song_length":$song_length},';
    }
  }
  return trackString;
}

class Song {
  String song_name;
  String record_side;
  int song_length;

  Song(this.song_name, this.record_side, this.song_length);

  factory Song.fromJson(dynamic json) {
    return Song(json["song_name"] as String, json["record_side"] as String,
        json["song_length"] as int);
  }
}
