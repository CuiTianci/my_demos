import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_demos/config/my_pages.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("My Demos"),
            floating: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildItem(index, context);
            }, childCount: kMyPages.length),
          )
        ],
      ),
    );
  }

  _buildItem(index, context) {
    MyPage page = kMyPages[index];
    return Card(
      child: ListTile(
        title: Row(
          children: <Widget>[
            Text(page.title),
            Expanded(
              child: Container(),
            ),
            Text(page.date)
          ],
        ),
        subtitle: Text(page.desc),
        onTap: () => Navigator.of(context).pushNamed(page.pageName),
      ),
    );
  }
}
