import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SlidePicDemo extends StatefulWidget {
  @override
  _SlidePicDemoState createState() => _SlidePicDemoState();
}

class _SlidePicDemoState extends State<SlidePicDemo> {
  var _itemCount = 50; //不包含广告位
  var _itemExtent = 150.0; //item宽度/高度，取决于scrollDirection
  var _adPicAlignment = 1.0;//默认图片显示位置
  var _adPosition = 25;//显示图片广告的位置
  var _adStartOffset;//记录图片进入屏幕时的偏移量
  var _scrollDirection = Axis.vertical;//滑动方向，实际上也支持横向滑动

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        _handleNotification(notification);
        return true;
      },
      child: Stack(
        children: <Widget>[
          ListView.builder(
            scrollDirection: _scrollDirection,
            itemExtent: _itemExtent,
            itemBuilder: (context, index) {
              if (index == _adPosition) {//在预设的位置上显示图片广告
                return Image.asset(
                    'assets/images/ct.jpeg',
                    fit: _scrollDirection == Axis.horizontal ? BoxFit.fitHeight : BoxFit.fitWidth,//滑动相对方向上要占满
                    alignment: _scrollDirection == Axis.horizontal ? Alignment(_adPicAlignment,0) : Alignment(0,_adPicAlignment),//通过Alignment改变图片显示位置
                );
              } else {
                return _buildItem(index < _adPosition ? index : index - 1);
              }
            },
            itemCount: _itemCount + 1,//增加了图片
            padding: const EdgeInsets.all(0),
          ),
        ],
      ),
    );
  }

  ///处理滑动
  _handleNotification(ScrollNotification notification) {
    var totalOffset = notification.metrics.viewportDimension - _itemExtent;//总偏移量=listView高度-Item高度
    var firstVisible = notification.metrics.extentBefore ~/ _itemExtent;//通过整除，计算出当前第一个可见的Item
    var lastVisible =
        _itemCount - notification.metrics.extentAfter ~/ _itemExtent;//通过整除，计算出当前最后一个可见的Item
    if (firstVisible <= _adPosition && _adPosition <= lastVisible - 1) {//图片完全处于屏幕中时
      if (null == _adStartOffset)//第一次，记录初始偏移量
        _adStartOffset = notification.metrics.extentBefore;
      var percent = (notification.metrics.extentBefore - _adStartOffset) /
          totalOffset;//之后的滑动中，计算相对偏移比例
      setState(() {
        _adPicAlignment = _calculateAlignment(1 - percent);//改变图片显示位置
      });
    }
    return true;
  }

  _buildItem(index) {
    return Container(
      color: _getSkipColor(index),
      child: Center(child: Text(index.toString())),
      height: _itemExtent,
      width: MediaQuery.of(context).size.width,
    );
  }

  /// 0 到 1 转化为 -1 到 1。
  /// 滑动偏移比例为0-1之间的小数，而Alignment的值为-1,1。
  /// 通过单位加减乘除，得到对应alignment。
  _calculateAlignment(percent) {
    var sourceUnit = (1.0 - 0.0) / 10000;
    var targetUnit = (1.0 - (-1.0)) / 10000;
    var offset = (percent - 0) / sourceUnit;
    var alignment = -1 + offset * targetUnit;
    if (alignment > 1.0) alignment = 1.0; //边界
    if (alignment < -1.0) alignment = -1.0;
    return alignment;
  }

  _getSkipColor(index) {
    switch (index % 5) {
      case 0:
        return Color.fromARGB(255, 241, 241, 184);
      case 1:
        return Color.fromARGB(255, 241, 201, 184);
      case 2:
        return Color.fromARGB(255, 241, 184, 228);
      case 3:
        return Color.fromARGB(255, 184, 241, 237);
      case 4:
        return Color.fromARGB(255, 184, 241, 204);
    }
  }
}
