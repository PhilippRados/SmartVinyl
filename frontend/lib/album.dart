import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_vinyl_app/main.dart';

class AlbumInfo extends StatefulWidget {
  AlbumInfo({dynamic this.album_data});
  final dynamic album_data;
  @override
  _AlbumInfoState createState() => _AlbumInfoState();
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
  return record_sides_widgets;
}

class _AlbumInfoState extends State<AlbumInfo> {
  dynamic selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(8))),
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
                                fontSize: 38,
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
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Container(
                    child: ListView.builder(
                      itemExtent: 60,
                      itemCount: widget.album_data.track_list.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {},
                          title: Text(
                            widget.album_data.track_list[index].item1,
                            style: TextStyle(
                                color: Color(0xffE9EDF1),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            ((Duration(
                                            milliseconds: widget.album_data
                                                .track_list[index].item3)
                                        .inSeconds) /
                                    60)
                                .toStringAsPrecision(3)
                                .replaceAll(".", ":"),
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
            ],
          ),
        ),
      ),
    );
  }
}
