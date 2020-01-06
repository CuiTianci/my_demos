import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_demos/pages/home_page.dart';
import 'package:my_demos/widgets/joy_stick.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_with_codeview/source_code_view.dart';

final kMyPages = <MyPage>[
  MyPage(
    sourceCodePath: 'lib/widgets/joy_stick.dart',
    child: JoyStickDemo(),
    title: 'JoyStick',
    date: '2020-01-06',
    desc: 'GestureDetector的使用',
  )
];

class MyPage extends StatelessWidget {
  final sourceCodePath;
  final child;
  final title;
  final date;
  final desc;
  final mPageName;
  final blogLink;

  const MyPage(
      {Key key,
      @required this.sourceCodePath,
      @required this.child,
      @required this.title,
      @required this.date,
      @required this.desc,
      this.mPageName,
      this.blogLink = 'https://www.baidu.com'});//TODO 修改链接

  String get pageName =>
      null != mPageName ? mPageName : child.runtimeType.toString();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          child,
          Positioned(
            top: 0.0,
            right: 0.0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.code),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return SourceCodePage(title, sourceCodePath,blogLink);
                    })),
              ),
            ),
          ),Positioned(
            top: 0.0,
            left: 0.0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SourceCodePage extends StatelessWidget {
  final title;
  final filePath;
  final blogLink;

  SourceCodePage(this.title, this.filePath,this.blogLink);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _buildActions(),
      ),
      body: SourceCodeView(
        filePath: filePath,
      ),
    );
  }

  _buildActions() {
    _launchURL(url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
    return [
      IconButton(
        icon: Icon(Icons.assignment),
        onPressed: () {
          _launchURL(blogLink);
        },
      )
    ];
  }
}

final Map<String, WidgetBuilder> kRoutingMap = {
  Navigator.defaultRouteName: (context) => HomePage(),
  for (MyPage page in kMyPages) page.pageName: (context) => page
};
