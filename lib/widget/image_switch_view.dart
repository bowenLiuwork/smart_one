import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_one/util/device_size_manager.dart';

class ImageSwitchView extends StatefulWidget {
  Uint8List image;
  int direction;
  Widget oldImageWidget;

  ImageSwitchView({Key key, @required this.image, this.direction = 0})
      : super(key: key);

  @override
  _ImageSwitchViewState createState() => _ImageSwitchViewState();
}

class _ImageSwitchViewState extends State<ImageSwitchView>
    with TickerProviderStateMixin {
  Uint8List oldImage;
  Uint8List newImage;
  Widget _oldImageWidget;
  AnimationController _controller;
  Animation<RelativeRect> _leftAnimation;
  Animation<RelativeRect> _rightAnimation;
  Animation<double> _fadeAnimation;

  final LinearGradient backgroundGradient = new LinearGradient(
      colors: [new Color(0x10000000), new Color(0x30000000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _leftAnimation = new RelativeRectTween(
            begin: RelativeRect.fromLTRB(-1000, 0, 0, 0),
            end: RelativeRect.fromLTRB(0, 0, 0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));
    _rightAnimation = new RelativeRectTween(
            begin: RelativeRect.fromLTRB(0, 0, -1000, 0),
            end: RelativeRect.fromLTRB(0, 0, 0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    oldImage = widget.image;
    newImage = oldImage;
    print('image initState-------------');
  }

  @override
  void didUpdateWidget(ImageSwitchView oldWidget) {
    _oldImageWidget = oldWidget.oldImageWidget;
    super.didUpdateWidget(oldWidget);
    print(
        "oldWidget ----- didUpdateWidget -- ${oldImage == widget.image} -- ${newImage == widget.image}");
  }

  @override
  Widget build(BuildContext context) {
    print(
        "oldWidget ----- build -- ${oldImage == widget.image} -- ${newImage == widget.image}");
    Widget view = SizedBox.expand(
      child: new Container(
        color: Colors.transparent,
        child: new Stack(
          children: <Widget>[
            new Align(
              alignment: Alignment.center,
              child: ExtendedImage.memory(
                widget.image,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      _controller.reset();
                      print('LoadState.loading ---- ');
                      if (_oldImageWidget != null) {
                        return _oldImageWidget;
                      }
                      break;
                    case LoadState.completed:
                      print('LoadState.completed ---- ');
                      _controller.forward();
                      Widget imageWidget = ExtendedRawImage(
                        image: state.extendedImageInfo?.image,
                      );
                      Widget currentWidget = Stack(
                        children: <Widget>[
                          getAnimationWidget(imageWidget),
                        ],
                      );
                      widget.oldImageWidget = imageWidget;
                      return currentWidget;
                      break;
                    case LoadState.failed:
                      _controller.reset();
                      print('LoadState.failed ---- ');
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );

    return view;
  }

  Widget getAnimationWidget(Widget imageWidget) {
    Widget showWidget = null;
    if (widget.direction < 0) {
      showWidget = PositionedTransition(
        rect: _leftAnimation,
        child: imageWidget,
      );
    } else if (widget.direction == 0) {
      showWidget = FadeTransition(
        opacity: _fadeAnimation,
        child: imageWidget,
      );
    } else {
      showWidget = PositionedTransition(
        rect: _rightAnimation,
        child: imageWidget,
      );
    }
    print('getAnimationWidget ---- ${showWidget == null}');
    return showWidget;
  }

  Widget oldWidget() {
    return Container(
      child: Stack(
        children: <Widget>[
          Image.memory(
            oldImage,
            fit: BoxFit.fill,
          ),
          Image.memory(
            newImage,
            fit: BoxFit.fill,
          )
        ],
      ),
    );
  }
}
