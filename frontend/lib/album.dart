import 'package:flutter/material.dart';

class AlbumInfo extends StatefulWidget {
  @override
  _AlbumInfoState createState() => _AlbumInfoState();
}

class _AlbumInfoState extends State<AlbumInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xff171518), Color(0xff42FBCF)],
        ),
      ),
      child: Scaffold(
        body: Column(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.chevron_left))
          ],
        ),
      ),
    );
  }
}
