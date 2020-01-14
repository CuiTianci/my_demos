import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_demos/pages/home_page.dart';
import 'package:my_demos/widgets/flutter_cn.dart';
import 'package:my_demos/widgets/joy_stick.dart';
import 'package:my_demos/widgets/slide_pic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_with_codeview/source_code_view.dart';

final kMyPages = <MyPage>[
  MyPage(
    sourceCodePath: 'lib/widgets/joy_stick.dart',
    child: JoyStickDemo(),
    title: 'JoyStick',
    date: '2020-01-06',
    desc: 'GestureDetector的使用',
    blogLink: 'https://blog.csdn.net/weixin_43879272/article/details/103882323',
    repoLink:
        'https://github.com/CuiTianci/my_demos/blob/master/lib/widgets/joy_stick.dart',
  ),
  MyPage(
    sourceCodePath: 'lib/widgets/slide_pic.dart',
    child: SlidePicDemo(),
    date: '2020-01-12',
    title: 'NotificationListener',
    desc: '用NotificationListener模仿猫眼电影首页广告滑动',
    blogLink: 'https://blog.csdn.net/weixin_43879272/article/details/103943009',
    repoLink: 'https://github.com/CuiTianci/my_demos/blob/master/lib/widgets/slide_pic.dart',
  ),MyPage(
    sourceCodePath: 'lib/widgets/flutter_cn.dart',
    child: FlutterCN(),
    date: '2020-01-14',
    title: 'FlutterWeb',
    desc: '浅尝辄止：Flutter开发Web的第0次尝试',
    blogLink: 'https://blog.csdn.net/weixin_43879272/article/details/103967636',
    repoLink: 'https://github.com/CuiTianci/my_demos/blob/master/lib/widgets/flutter_cn.dart',
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
  final repoLink;

  const MyPage(
      {Key key,
      @required this.sourceCodePath,
      @required this.child,
      @required this.title,
      @required this.date,
      @required this.desc,
      this.mPageName,
      this.blogLink = 'https://blog.csdn.net/weixin_43879272',
      this.repoLink = 'https://github.com/CuiTianci'});

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
                  return SourceCodePage(
                      title, sourceCodePath, blogLink, repoLink);
                })),
              ),
            ),
          ),
          Positioned(
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
  final repoLink;

  SourceCodePage(this.title, this.filePath, this.blogLink, this.repoLink);

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
        icon: Image.asset('assets/images/csdn.png'),
        onPressed: () {
          _launchURL(blogLink);
        },
      ),
      IconButton(
        icon: Image.asset('assets/images/github.png'),
        onPressed: () {
          _launchURL(repoLink);
        },
      ),
    ];
  }
}

final Map<String, WidgetBuilder> kRoutingMap = {
  Navigator.defaultRouteName: (context) => HomePage(),
  for (MyPage page in kMyPages) page.pageName: (context) => page
};
