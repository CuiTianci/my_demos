import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlutterCN extends StatefulWidget {
  @override
  _FlutterCNState createState() => _FlutterCNState();
}

class _FlutterCNState extends State<FlutterCN>
    with SingleTickerProviderStateMixin {
  final _screenHeight = 1080.0;
  final _screenWidth = 1920.0; //预设屏幕宽高
  var _titleExtent = 380.0;
  final _defaultPicExtent = 500.0; //pic默认高度
  var _pictureExtent = 500.0;
  var _listExtent = 330.0;
  var _isSmall = false;
  TabController _tabController;
  ScrollController _scrollController;
  TextStyle _tabStyle = TextStyle(
      color: Colors.black87, fontSize: 15.0, fontWeight: FontWeight.w500);
  var _tabs = ['视频资源', '插件推荐', 'Codelabs', '中文社区', '使用镜像'];
  var hasEnoughTabSpace = true;
  final _listTitleStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0);
  final _listLinkStyle = TextStyle(fontSize: 15.0, color: Colors.deepOrange);
  final _listMargin = const EdgeInsets.only(top: 80.0);
  final _listPadding = EdgeInsets.symmetric(horizontal: 200.0);
  var _currentScreenWidth;
  var _showTabIndicator = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showTabIndicator = !(_scrollController.offset <= _listPadding.top);
        });
        if (_scrollController.offset > _listPadding.top) {
          //滑动过程中，根据当前滑动距离，改变tab选中
          _tabController.index =
              (_scrollController.offset - _listPadding.top) ~/
                  (_listExtent + _listPadding.top * 3);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    _currentScreenWidth = MediaQuery.of(context).size.width;//当前屏幕距离
    _isSmall = _currentScreenWidth <= 776.0;
    hasEnoughTabSpace = _currentScreenWidth > 1000.0; //TODO 跟屏幕实际高度关联起来
    _pictureExtent = _defaultPicExtent * (_currentScreenWidth / _screenWidth);
    print(
        'pictureExtent:$_pictureExtent,current:$_currentScreenWidth, total:$_screenWidth,result:${_currentScreenWidth / _screenWidth}');
    return Scaffold(
      appBar: AppBar(
        actions: hasEnoughTabSpace
            ? null
            : <Widget>[
                DropdownButton(
                  icon: Icon(Icons.menu),
                  onChanged: (value) {
                    _scrollController.animateTo(
                        _titleExtent +
                            _pictureExtent +
                            (_listExtent + _listMargin.top) * value,
                        duration: Duration(microseconds: 800),
                        curve: Curves.bounceInOut);
                  },
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      child: Text(_tabs[0]),
                      value: 0,
                    ),
                    DropdownMenuItem(
                      child: Text(_tabs[1]),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text(_tabs[2]),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text(_tabs[3]),
                      value: 3,
                    ),
                    DropdownMenuItem(
                      child: Text(_tabs[4]),
                      value: 4,
                    ),
                  ],
                ),
                SizedBox(
                  width: 60.0,
                )
              ],
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Image.asset(
                'assets/images/icon.ico',
                height: 36.0,
              ),
              SizedBox(
                width: 18.0,
              ),
              Text(
                'Flutter',
                style: TextStyle(fontSize: 25.0, color: Colors.black87),
              ),
              Expanded(
                child: Container(),
              ),
              if (hasEnoughTabSpace)
                Container(
                  width: 500.0,
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Colors.deepOrange,
                    controller: _tabController,
                    indicatorWeight: _showTabIndicator ? 4.0 : 0.1,
                    tabs: <Widget>[
                      for (int i = 0; i < _tabController.length; i++)
                        _buildTabs(i),
                    ],
                    onTap: (index) {
                      _scrollController.animateTo(
                          _titleExtent +
                              _pictureExtent +
                              (_listExtent + _listMargin.top) * index,
                          duration: Duration(microseconds: 800),
                          curve: Curves.bounceInOut);
                    },
                  ),
                ),
              if (hasEnoughTabSpace)
                SizedBox(
                  width: 15.0,
                ),
              if (hasEnoughTabSpace)
                FlatButton(
                  color: Colors.deepOrange,
                  child: Text(
                    '开始使用',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0),
                  ),
                  onPressed: () {},
                )
            ],
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          _buildTitle(),
          _buildPic(),
          _buildVideo(),
          _buildPlugins(),
          _buildCode(),
          _buildCommunity(),
          _buildMirror()
        ],
      ),
    );
  }

  _buildMirror() {
    return Container(
      child: Center(
        child: Text(
          _tabs[4],
          style: _listTitleStyle,
        ),
      ),
      margin: _listMargin,
      color: Colors.green,
      height: _listExtent,
    );
  }

  _buildCommunity() {
    return Container(
      child: Center(
        child: Text(
          _tabs[3],
          style: _listTitleStyle,
        ),
      ),
      margin: _listMargin,
      color: Colors.amberAccent,
      height: _listExtent,
    );
  }

  _buildCode() {
    return Container(
      child: Center(
        child: Text(
          _tabs[2],
          style: _listTitleStyle,
        ),
      ),
      margin: _listMargin,
      color: Colors.brown,
      height: _listExtent,
    );
  }

  _buildVideo() {
    return Container(
      child: Center(
        child: Text(
          _tabs[0],
          style: _listTitleStyle,
        ),
      ),
      margin: _listMargin,
      color: Colors.orange,
      height: _listExtent,
    );
  }

  _buildPlugins() {
    return Container(
      margin: _listMargin,
      padding: _listPadding,
      height: _listExtent,
      color: Colors.yellow,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                _tabs[1],
                style: _listTitleStyle,
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                '更多插件 >',
                style: _listLinkStyle,
              )
            ],
          ),
          Expanded(
            child: Container(),
          ),
          Container(
            height: _listExtent - 80.0,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return _buildPluginItem(index);
              },
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 50.0,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  _buildPluginItem(int index) {
    return Container(
      width: (_currentScreenWidth - _listPadding.horizontal - 50.0 * 2) / 3,
      //刚好占满listView的宽度

      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(15.0)),
    );
  }

  _buildPic() {
    return Stack(
      alignment: const Alignment(0, 1),
      children: <Widget>[
        Container(
          height: _pictureExtent,
          color: Colors.red,
        ),
        Image.asset(
          'assets/images/back_scene.png',
          height: _pictureExtent,
          fit: BoxFit.fitHeight,
        ),
        Image.asset(
          'assets/images/front_scene.png',
          height: _pictureExtent,
          fit: BoxFit.fitHeight,
        ),
      ],
    );
  }

  _buildTitle() {
    return Container(
      height: _titleExtent,
      color: Colors.green,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Flutter 1.12 发布',
              style: TextStyle(fontSize: 65.0, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0),
              width: 700.0,
              child: Text(
                'Flutter 是 Google开源的UI工具包，帮助开发者通过一套代码库高效构建多平台精美应用，支持移动、Web、桌面和嵌入式平台。',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0,
                    color: Colors.black87,
                    height: 1.5),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  color: Colors.deepOrange,
                  onPressed: () {},
                  child: Text(
                    '中文文档',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  width: 50.0,
                ),
                FlatButton(
//                          color: Colors,
                  onPressed: () {},
                  child: Text(
                    '官方文档（英文）',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildTabs(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(_tabs[index], style: _tabStyle),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
