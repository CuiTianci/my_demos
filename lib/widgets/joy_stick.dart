import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class JoyStick extends StatefulWidget {
  @override
  _JoyStickState createState() => _JoyStickState();

  final stickSide; //摇杆区域边长
  final stickBgRadius; //摇杆盘半径
  final stickRadius; //摇杆指示器半径
  final Function(Offset) onSpeedChanged; //速度变化回调

  JoyStick(
      {@required this.onSpeedChanged,
      this.stickSide = 300.0,
      this.stickBgRadius = 50.0,
      this.stickRadius = 20.0}) {
    assert(this.stickRadius > 0.0);
    assert(this.stickBgRadius > 0.0);
    assert(this.stickRadius > 0.0);
    assert(this.onSpeedChanged != null);
    assert(this.stickSide > stickBgRadius * 2);
    assert(this.stickBgRadius > stickRadius);
  }
}

class _JoyStickState extends State<JoyStick> {
  var _stickBgOffset; //遥感盘圆心
  var _stickOffset; //摇杆圆心
  var _defaultStickBgOffset; //摇杆盘默认圆心，用于结束滑动式回滚到初始位置
  var _defaultStickOffset;
  var _isDraggingEffectively = false; //有效拖拽

  @override
  void initState() {
    super.initState();
    _defaultStickBgOffset = Offset(
        //以触控区的中心作为摇杆初始圆心位置，但Position的坐标，为Widget矩形左上角的位置，因此需要根据圆心坐标和半径求出真正的位置坐标
        sqrt(pow(widget.stickSide / 2 - widget.stickBgRadius, 2)),
        sqrt(pow(widget.stickSide / 2 - widget.stickBgRadius, 2)));
    _defaultStickOffset = Offset(
        sqrt(pow(widget.stickSide / 2 - widget.stickRadius, 2)),
        sqrt(pow(widget.stickSide / 2 - widget.stickRadius, 2)));
    _stickBgOffset = _defaultStickBgOffset;
    _stickOffset = _defaultStickOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.yellow.withAlpha(100),
        child: GestureDetector(
          onPanDown: (DragDownDetails detail) {
            Offset bgOffset = _calculateBgOffset(detail.localPosition);
            if (bgOffset.dx >= 0.0 &&
                bgOffset.dx <= widget.stickSide - widget.stickBgRadius * 2 &&
                bgOffset.dy >= 0.0 &&
                bgOffset.dy <= widget.stickSide - widget.stickBgRadius * 2) {
              _isDraggingEffectively =
                  true; //避免摇杆显示不全，因此实际触控区比GestureDetector小一点，标记属于有效滑动。
              setState(() {
                _stickBgOffset = bgOffset;
                _stickOffset = _calculateStickOffset(
                    detail.localPosition); //摇杆盘满足条件时，摇杆必定满足条件（因为摇杆必定在内部）
              });
            }
          },
          onPanCancel: () {
            print("panCancel");
          },
          onPanEnd: (_) {//滑动结束
            _isDraggingEffectively = false;
            widget.onSpeedChanged(Offset(0.0, 0.0));//速度变为0
            setState(() {//位置回滚
              _stickBgOffset = _defaultStickBgOffset;
              _stickOffset = _defaultStickOffset;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (!_isDraggingEffectively) return;
            if (_isStickInBg(details.localPosition)) {//当触控点在遥感盘内部-摇杆半径时
              setState(() {
                _stickOffset = _calculateStickOffset(details.localPosition);
              });
            } else {
              setState(() {
                _stickOffset = _getRealOffset(details.localPosition);
              });
            }
            _calculateV(_stickOffset); //计算速度
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                //左上角60.0,297.3
                height: widget.stickSide,
                width: widget.stickSide,
                color: Colors.brown.withAlpha(100),
              ),
              Positioned(
                left: _stickBgOffset.dx,
                top: _stickBgOffset.dy,
                child: CircleAvatar(
                  radius: widget.stickBgRadius,
                  backgroundColor: Colors.grey.withAlpha(100),
                ),
              ),
              Positioned(
                left: _stickOffset.dx,
                top: _stickOffset.dy,
                child: CircleAvatar(
                  radius: widget.stickRadius,
                  backgroundColor: Colors.black.withAlpha(100),
                ),
              )
            ],
          ),
        ));
  }

  ///通过圆心位置求摇杆盘实际位置
  ///已知圆心和半径，可求。
  _calculateBgOffset(fingerOffset) {
    var dx = sqrt(pow(fingerOffset.dx - widget.stickBgRadius, 2)) *
        (fingerOffset.dx > widget.stickBgRadius ? 1 : -1);
    var dy = sqrt(pow(fingerOffset.dy - widget.stickBgRadius, 2)) *
        (fingerOffset.dy > widget.stickBgRadius ? 1 : -1);
    return Offset(dx, dy);
  }

  ///判断如果以当前触控点为圆心，摇杆会不会超出遥感盘范围
  _isStickInBg(fingerOffset) {
    var radius = widget.stickBgRadius - widget.stickRadius;
    var bgX = _stickBgOffset.dx + widget.stickBgRadius; //遥感盘的圆心
    var bgY = _stickBgOffset.dy + widget.stickBgRadius;
    return pow(fingerOffset.dx - bgX, 2) + pow(fingerOffset.dy - bgY, 2) <=
        pow(radius, 2);
  }

  ///通过圆心位置求摇杆位置
  ///已知圆心和半径，可求。
  _calculateStickOffset(fingerOffset) {
    var dx = sqrt(pow(fingerOffset.dx - widget.stickRadius, 2)) *
        (fingerOffset.dx > widget.stickRadius ? 1 : -1);
    var dy = sqrt(pow(fingerOffset.dy - widget.stickRadius, 2)) *
        (fingerOffset.dy > widget.stickRadius ? 1 : -1);
    return Offset(dx, dy);
  }

  ///触控点处在遥感盘外部时,计算摇杆位置
  _getRealOffset(fingerOffset) {
    var r = widget.stickBgRadius - widget.stickRadius;
    var x1 = _stickBgOffset.dx + widget.stickBgRadius; //遥感盘的圆心
    var y1 = _stickBgOffset.dy + widget.stickBgRadius;
    var x2 = fingerOffset.dx;
    var y2 = fingerOffset.dy;
    if (x1 == x2) {
      //斜率不存在的情况
      return Offset(x1, y1 + r * (y2 > y1 ? 1 : -1));
    }
    var k = (y2 - y1) / (x2 - x1);

    ///遥感盘的圆心，与手指触控点连成的直线，与摇杆内圆的交点就是摇杆的圆心。
    ///两点，直线方程，(x - x1) / (x2 - x1) = (y - y1) / (y2 - y1)
    ///内圆方程：点到圆心的距离等于半径。pow(x - x1) + pow(y - y1) = pow(r)
    ///联立，得到二元一次方程。
    var a = pow(k, 2) + 1;
    var b = (2 * pow(k, 2) * x1 + 2 * x1) * -1;
    var c = (pow(k, 2) + 1) * pow(x1, 2) - pow(r, 2);
    var m = pow(b, 2) - 4 * a * c; //m = b方减去四ac。

    ///过圆心，肯定有两个解，省略判断条件m > 0
    var rx1 = ((-b + sqrt(m)) / (2 * a));
    var rx2 = ((-b - sqrt(m)) / (2 * a));
    var realX = x2 > x1 ? max(rx1, rx2) : min(rx1, rx2);
    var realY = k * (realX - x1) + y1;
    return _calculateStickOffset(Offset(realX, realY));
  }

  ///计算小球速度
  _calculateV(_stickOffset) {
    var stickOx = _stickOffset.dx + widget.stickRadius; //摇杆圆心
    var stickOy = _stickOffset.dy + widget.stickRadius;

    ///速度是矢量，先求一下大小,设置滑动到边缘为五倍速度，圆心速度为0，单位长度，单位增加。
    var oX1 = _stickBgOffset.dx + widget.stickBgRadius; //遥感盘的圆心
    var oY1 = _stickBgOffset.dy + widget.stickBgRadius;
    var maxX = widget.stickBgRadius - widget.stickRadius; //最大直线位移
    var unitX = maxX / 5; //单位长度
    var x = sqrt(pow(stickOx - oX1, 2) + pow(stickOy - oY1, 2)); //实际位移
    var v = unitX == 0.0 ? 0.0 : x / unitX; //速度
    var alpha = _getRadToPositiveX(Offset(stickOx, stickOy), Offset(oX1, oY1));//获得速度与X轴正向夹角
    var vX = v * cos(alpha);
    var vY = v * sin(alpha);
    widget.onSpeedChanged(Offset(vX, vY));
  }

  ///p为点，O为原点，求pO与x轴正向夹角
  _getRadToPositiveX(p, O) {
    if (p.dx == O.dx) {
      return p.dy > O.dy ? 3 / 2 * pi : pi / 2;
    }
    var k = (p.dy - O.dy) / (p.dx - O.dx);
    var alphaToX = atan(k); //arctan，直线斜倾角（与x轴夹角）结果为-pi/2到pi/2之间
    var alphaToPositiveX;
    //一象限rad * -1，二象限pi - rad，三象限rad * -1 + pi，四象限2 * pi - rad
    if (p.dx > O.dx && (p.dy <= O.dy)) {
      //1
      alphaToPositiveX = alphaToX * -1;
    } else if (p.dx <= O.dx && p.dy <= O.dy) {
      //2
      alphaToPositiveX = pi - alphaToX;
    } else if (p.dx <= O.dx && p.dy > O.dy) {
      //3
      alphaToPositiveX = alphaToX * -1 + pi;
    } else {
      //4
      alphaToPositiveX = 2 * pi - alphaToX;
    }
    return alphaToPositiveX;
  }

  @override
  void dispose() {
    super.dispose();
  }
}


///使用示例
class JoyStickDemo extends StatefulWidget {
  @override
  _JoyStickDemoState createState() => _JoyStickDemoState();
}

class _JoyStickDemoState extends State<JoyStickDemo> {
  var _ballRadius = 15.0; //小球半径
  var _ballOffsetX = 0.0;
  var _ballOffsetY = 0.0;
  var _vX = 0.0; //初始速度为0
  var _vY = 0.0;
  var _unitV = 0.8; //单位速度
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (value) {
      //1000/60，即每秒60帧。
      if (_vX == 0 && _vY == 0) return;
      var newX = _ballOffsetX + _unitV * _vX;
      var newY = _ballOffsetY +
          _unitV * _vY * -1; //乘-1的原因是数学坐标y正方向向上，而Stack的位置坐标y轴正方向向下
      var rightBound = MediaQuery.of(context).size.width -
          2 * _ballRadius; //右边界--屏幕宽度减去小球直径。
      var bottomBound = MediaQuery.of(context).size.height - 2 * _ballRadius;
      if (newX < 0.0) newX = 0.0; //左边界
      if (newX > rightBound) newX = rightBound; //右边界
      if (newY < 0.0) newY = 0.0;
      if (newY > bottomBound) newY = bottomBound;
      if (newX.isNaN || newY.isNaN)
        return; //即便已经解决了会出现NaN的情况（x1 == x2,斜率不存在），但还是加一下判断吧，以防万一。
      setState(() {
        _ballOffsetX = newX;
        _ballOffsetY = newY;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.greenAccent,
        ),
        Positioned(
          left: _ballOffsetX,
          top: _ballOffsetY,
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: _ballRadius,
          ),
        ),
        Positioned(
            bottom: 0.0,
            right: 0.0,
            child: JoyStick(
              onSpeedChanged: (offset) {
                setState(() {
                  _vX = offset.dx;
                  _vY = offset.dy;
                });
              },
            ))
      ],
    );
  }
}
