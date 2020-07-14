//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Feed {
  Feeds livefeed = new Feeds();
  String pictureURL;
  String link;
  String details;
  Feed();
  setUrl(String url) {
    this.pictureURL = url;
  }

  setDetails(String detail) {
    this.details = detail;
  }

  setLink(String link) {
    this.link = link;
  }

  Future getFeeds() async {
    String raw;
    List<String> pic = [];
    List<String> link = [];
    List<String> detai = [];
    bool loading = true;
    try {
      loading = true;
      await http.get("https://covid-19.kapook.com/news").then((value) {
        raw = value.body;
      }).whenComplete(() {
        List<String> splitRaw = raw.split('\n');
        splitRaw.forEach((element) {
          //print(element);
          if (element.contains('a target="_blank"')) {
            RegExp reg = RegExp('src=\"(.+?)\">');
            RegExp reg2 = RegExp('href=\"(.+?)\">');
            final mt = reg.firstMatch(element);
            final mt2 = reg2.firstMatch(element);
            pic.add(mt.group(1));
            link.add(mt2.group(1).replaceFirst(':', 's:'));
            print(mt2.group(1));
          }
          if (element.contains('<h3>') && !element.contains('<a href')) {
            //print(element);
            RegExp reg = RegExp('<h3>(.+?)</h3>');
            final mt = reg.firstMatch(element);
            detai.add(mt.group(1));
            //print(mt.group(1));
          }
        });

        print(detai.length);
        loading = false;
      });
    } catch (e) {
      print(e);
    }
    if (!loading) {
      for (int i = 0; i < pic.length; i++) {
        Feed temp = new Feed();
        temp.setUrl(pic[i]);
        temp.setDetails(detai[i]);
        temp.setLink(link[i]);
        livefeed.addFeed(temp);
      }
    }
  }
}

class Feeds {
  List<Feed> feeds = [];

  Feeds();

  addFeed(Feed value) {
    feeds.add(value);
  }
}
