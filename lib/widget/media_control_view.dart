import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/text_config.dart';

abstract class OnControlListener {
  void onUp();

  void onDown();

  void onPlay();

  void onPause();

  void changeSound(var changeInfo);

  void onSeek(double value);
}

class MediaControlView extends StatefulWidget {
  OnControlListener controlListener;
  num allSize;
  bool upEnable;
  bool isPlaying;
  bool downEnable;

  MediaControlView(
      {Key key,
      this.controlListener,
      this.upEnable = false,
      this.isPlaying = false,
      this.downEnable = false,
      this.allSize = 0})
      : super(key: key);

  @override
  _MediaControlViewState createState() => _MediaControlViewState();
}

class _MediaControlViewState extends State<MediaControlView> {
  @override
  Widget build(BuildContext context) {
    Row row = new Row(
      children: <Widget>[
        MaterialButton(
          onPressed: () {
            _upClick();
          },
          minWidth: 10,
          child: Icon(
            Icons.first_page,
            color: _getColor(widget.upEnable),
          ),
        ),
        MaterialButton(
          onPressed: () {
            setState(() {
              widget.isPlaying = !widget.isPlaying;
            });
            if(widget.isPlaying) {
              _playClick();
            }else {
              _pauseClick();
            }
          },
          minWidth: 10,
          child: widget.isPlaying
              ? Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white,
                )
              : Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                ),
        ),
        MaterialButton(
          onPressed: () {
            _downClick();
          },
          minWidth: 10,
          child: Icon(
            Icons.last_page,
            color: _getColor(widget.downEnable),
          ),
        ),
        Expanded(
          child: Container(),
        ),
        MaterialButton(
          onPressed: () {
            _upClick();
          },
          minWidth: 10,
          child: Icon(Icons.volume_up, color: Colors.white),
        ),
      ],
    );

    Container container = new Container(
      height: 45,
      child: row,
    );

    return container;
  }

  _getColor(bool enable) {
    return enable ? Colors.white : Color(0xff929ba7);
  }

  _seekProgress(double value) {
    widget.controlListener.onSeek(value);
  }

  _upClick() {
    widget.controlListener?.onUp();
  }

  _downClick() {
    widget.controlListener?.onDown();
  }

  _playClick() {
    widget.controlListener?.onPlay();
  }

  _pauseClick() {
    widget.controlListener?.onPause();
  }
}
