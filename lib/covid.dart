import 'dart:convert';

import 'package:cowith19/bloc/imgfeed_bloc.dart';
import 'package:cowith19/bloc/imgfeed_event.dart';

import 'package:cowith19/main.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:cowith19/ObjectCovid.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:cowith19/Feed.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bloc/imgfeed_bloc.dart';

class Covid19 extends StatefulWidget {
  _Covid19 createState() => _Covid19();
}

class WorldData {
  String name;
  int value;
  Color color;
  WorldData(String name, int value, Color color) {
    this.name = name;
    this.value = value;
    this.color = color;
  }
}

class TimelineData {
  int newCases;
  int newDeaths;
  int totalCases;
  int day;
  TimelineData(this.day, this.newCases, this.newDeaths, this.totalCases);

  @override
  String toString() {
    return ' $day newCase: $newCases, newDeaths: $newDeaths, total: $totalCases';
  }
}

class _Covid19 extends State<Covid19> {
  ImgfeedBloc _imgfeedBlock;

  String user = 'none';
  int totalRecovered = 0;
  int totalDeaths = 0;
  int totalUnresolved = 0;

  List<TimelineData> countryData = [];

  String dropdownValue = 'สถานการณ์ทั่วโลก';
  final format = new NumberFormat();
  ObjectCovid covidWorld;
  Feed livefeed = new Feed();

  List<charts.Series<WorldData, dynamic>> _seriesPieData;
  List<charts.Series<TimelineData, int>> _seriesChartData;

  bool pieLoading = false;
  //PageController _controller;
  int currentPage = 0;

  bool green = true;
  bool red = true;
  bool blue = true;

  String date = DateFormat('kk:mm:ss > EEE d MMM y').format(DateTime.now());

  Future getWorldCovid() async {
    setState(() {
      date = DateFormat('kk:mm:ss > EEE d MMM y').format(DateTime.now());
      _seriesPieData = [];
      _seriesChartData.clear();
      countryData.clear();
      pieLoading = true;
    });

    try {
      if (dropdownValue.contains('ทั่วโลก')) {
        http.Response res = await http
            .get('https://api.thevirustracker.com/free-api?global=stats');

        if (res.statusCode == 200) {
          // print(res.body);
          var resp = res.body;
          //print(json.decode(resp));
          if (resp.contains("<br ")) {
            var temp = resp.split('\n');
            temp.removeAt(0);
            temp.removeAt(0);
            temp.removeAt(0);
            temp.removeAt(0);
            //temp.removeAt(0);
            //print(temp.toList());
            resp = "";
            for (var item in temp) {
              resp += item;
            }
            // print(resp);
          }
          // print('1');
          Map parsed = json.decode(resp);
          // print('2');
          covidWorld = ObjectCovid.fromJson(parsed);
          //print(covidWorld.results.map((e) => e));
          totalRecovered = covidWorld.results[0].totalRecovered;
          totalUnresolved = covidWorld.results[0].totalUnresolved;
          totalDeaths = covidWorld.results[0].totalDeaths;
        }

        var pieData = [
          new WorldData("หายแล้ว", totalRecovered, Colors.orange),
          new WorldData("รักษาตัว", totalUnresolved, Colors.red),
          new WorldData("เสียชีวิต", totalDeaths, Colors.red[300]),
        ];

        setState(() {
          pieLoading = false;
          _seriesPieData.add(charts.Series(
            data: pieData,
            domainFn: (WorldData data, index) => data.name,
            measureFn: (WorldData data, index) => data.value,
            labelAccessorFn: (WorldData data, index) =>
                '${data.name} : ${format.format(data.value)} ราย',
            colorFn: (WorldData data, index) =>
                charts.ColorUtil.fromDartColor(data.color),
            id: 'Today Feed',
          ));
        });
      } else {
        String url =
            'https://api.thevirustracker.com/free-api?countryTimeline=TH';
        switch (dropdownValue) {
          case 'ประเทศไทย':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=TH';
            break;
          case 'ประเทศอเมริกา':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=US';
            break;
          case 'ประเทศญี่ปุ่น':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=JP';
            break;
          case 'ประเทศอินเดีย':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=IN';
            break;
          case 'ประเทศจีน':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=CN';
            break;
          case 'ประเทศบราซิล':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=BR';
            break;
          case 'ประเทศรัสเซีย':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=RU';
            break;
          case 'ประเทศเยอรมัน':
            url = 'https://api.thevirustracker.com/free-api?countryTimeline=DE';
            break;
        }
        http.Response res = await http.get(url);

        if (res.statusCode == 200) {
          //print(res.body);
          var resp = res.body;

          if (resp.contains("<br ")) {
            var temp = resp.split('\n');
            temp.removeAt(0);
            temp.removeAt(0);
            temp.removeAt(0);
            temp.removeAt(0);
            temp.removeAt(0);
            //print(temp.toList());
            resp = "";
            for (var item in temp) {
              resp += item;
            }
            //print(resp);
          }

          //Map parsed = json.decode(resp);
          //debugPrint(parsed.toString());

          var split = resp.toString().split(',');
          dynamic nCase, nDeath, total;
          //extract json timeline
          int index = 0;
          for (var a in split) {
            print(a);
            if (a.contains('new_daily_cases')) {
              index++;
              //RegExp reg = new RegExp('([0-9]+/[0-9]+/[0-9]+)');
              RegExp reg2 = new RegExp(':([0-9]+)');

              //final t = reg.firstMatch(a);
              final t2 = reg2.firstMatch(a);
              //date = t.group(1);
              try {
                nCase = t2.group(1);
              } catch (e) {
                nCase = '0';
              }
              continue;
              //print(date+ ' '+nCase);
            }
            if (a.contains('new_daily_deaths')) {
              RegExp reg = new RegExp('([0-9]+)');
              final t = reg.firstMatch(a);
              nDeath = t.group(1);
              continue;
              //print(nDeath+",");
            }
            if (a.contains('total_cases')) {
              RegExp reg = new RegExp('([0-9]+)');
              final t = reg.firstMatch(a);
              total = t.group(1);
              continue;
              //print(total);
            }
            if (nCase != null && nDeath != null && total != null) {
              countryData.add(new TimelineData(index, int.parse(nCase),
                  int.parse(nDeath), int.parse(total)));

              nCase = null;
              nDeath = null;
              total = null;
            }
          }
          // for (var item in countryData) {
          //   print(item.toString());
          // }
          //covidWorld = ObjectCovid.fromJson(parsed);
          //print(covidWorld.results.map((e) => e));
          // totalRecovered = covidWorld.results[0].totalRecovered;
          // totalUnresolved = covidWorld.results[0].totalUnresolved;
          // totalDeaths = covidWorld.results[0].totalDeaths;
        }

        setState(() {
          pieLoading = false;
          setUpLine();
          //countryData = countryData;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void setUpLine() {
    //_seriesChartData.clear();
    // _imgfeedBlock.add(ImgfeedEvent.add(
    //     countryData,
    //     charts.Series(
    //       data: countryData,
    //       colorFn: (datum, index) =>
    //           charts.MaterialPalette.deepOrange.shadeDefault,
    //       domainFn: (TimelineData data, index) => data.day,
    //       measureFn: (TimelineData data, index) => data.totalCases,
    //       labelAccessorFn: (TimelineData data, index) =>
    //           '${data.newDeaths} : ${format.format(data.newCases)} ราย',
    //       id: 'ติดเชื้อ',
    //     )));

    // if (blue)
    //   _seriesChartData.add(charts.Series(
    //     data: countryData,
    //     colorFn: (datum, index) => charts.MaterialPalette.blue.shadeDefault,
    //     domainFn: (TimelineData data, index) => data.day,
    //     measureFn: (TimelineData data, index) => data.newCases,
    //     labelAccessorFn: (TimelineData data, index) =>
    //         '${data.newDeaths} : ${format.format(data.newCases)} ราย',
    //     id: 'ติดเชื้อรายใหม่',
    //   ));
    // if (green)
    //   _seriesChartData.add(charts.Series(
    //     data: countryData,
    //     colorFn: (datum, index) => charts.MaterialPalette.green.shadeDefault,
    //     domainFn: (TimelineData data, index) => data.day,
    //     measureFn: (TimelineData data, index) => data.newDeaths,
    //     labelAccessorFn: (TimelineData data, index) =>
    //         '${data.newDeaths} : ${format.format(data.newCases)} ราย',
    //     id: 'ตายรายใหม่',
    //   ));

    // if (red)
    //   _seriesChartData.add(charts.Series(
    //     data: countryData,
    //     colorFn: (datum, index) =>
    //         charts.MaterialPalette.deepOrange.shadeDefault,
    //     domainFn: (TimelineData data, index) => data.day,
    //     measureFn: (TimelineData data, index) => data.totalCases,
    //     labelAccessorFn: (TimelineData data, index) =>
    //         '${data.newDeaths} : ${format.format(data.newCases)} ราย',
    //     id: 'ติดเชื้อ',
    //   ));
  }

  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _imgfeedBlock = ImgfeedBloc();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    FirebaseAuth.instance.currentUser().then((value) {
      user = value.email.toString();
    });
    // _controller = PageController();

    _seriesChartData = List<charts.Series<TimelineData, int>>();
    getWorldCovid();
    //Feed _feed = new Feed();
    livefeed.getFeeds().whenComplete(() {
      // print(livefeed.livefeed.feeds[0].pictureURL);
      // print(livefeed.livefeed.feeds[0].details);
      print('FINISHED');
    });

    _seriesPieData = List<charts.Series<WorldData, dynamic>>();
  }

  Widget pageView(BuildContext context) {
    return PageView(
      onPageChanged: (value) {
        setState(() {
          currentPage = value;
        });
      },
      physics: ClampingScrollPhysics(),
      allowImplicitScrolling: true,
      scrollDirection: Axis.vertical,
      children: [
        !pieLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: dropdownValue.contains('ทั่วโลก')
                          ? Text(
                              "อัพเดทล่าสุด " + date,
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(fontFamily: 'Slab', fontSize: 10),
                            )
                          : Container()),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.all(8),
                    child: SizedBox(
                        width: double.infinity,
                        height: dropdownValue.contains('ทั่วโลก')
                            ? MediaQuery.of(context).size.height / 2
                            : MediaQuery.of(context).size.height / 1.35,
                        //margin: EdgeInsets.only(top: 100, bottom: 100),
                        child: dropdownValue.contains('ทั่วโลก')
                            ? charts.PieChart(
                                _seriesPieData,
                                animate: true,
                                animationDuration: Duration(milliseconds: 600),
                                defaultRenderer: new charts.ArcRendererConfig(
                                    customRendererId: 'test',
                                    arcWidth: 300,
                                    startAngle: 2,
                                    arcRendererDecorators: [
                                      new charts.ArcLabelDecorator(
                                        labelPosition:
                                            charts.ArcLabelPosition.auto,
                                      )
                                    ]),
                              )
                            : PageView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                    BlocConsumer<ImgfeedBloc,
                                        List<charts.Series<TimelineData, int>>>(
                                      buildWhen: (previous, current) {
                                        return true;
                                      },
                                      listener: (context, state) {
                                        print('added');
                                      },
                                      builder: (context, _seriesChartDataa) {
                                        //print(_seriesChartDataa.toList());
                                        return charts.LineChart(
                                          _seriesChartDataa,
                                          animate: true,
                                          animationDuration:
                                              Duration(milliseconds: 300),
                                          defaultRenderer:
                                              new charts.LineRendererConfig(
                                                  includeArea: false,
                                                  stacked: false,
                                                  strokeWidthPx: 3),
                                          behaviors: [
                                            //new charts.PanBehavior(),
                                            new charts.PanAndZoomBehavior(),
                                            new charts.SeriesLegend(
                                                position:
                                                    charts.BehaviorPosition.top,
                                                entryTextStyle:
                                                    charts.TextStyleSpec(
                                                        fontSize: 9)),
                                            new charts.ChartTitle(
                                              'วัน',
                                              behaviorPosition: charts
                                                  .BehaviorPosition.bottom,
                                              titleOutsideJustification: charts
                                                  .OutsideJustification
                                                  .middleDrawArea,
                                            ),
                                            new charts.ChartTitle(
                                              'ราย',
                                              titleStyleSpec:
                                                  charts.TextStyleSpec(
                                                      fontSize: 14),
                                              behaviorPosition:
                                                  charts.BehaviorPosition.start,
                                              titleOutsideJustification: charts
                                                  .OutsideJustification
                                                  .middleDrawArea,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              color: Colors.cyan,
                                              width: 8,
                                              height: 38,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              ' ติดเชื้อรายใหม่: ${format.format(countryData.last.newCases)} ราย',
                                              style: TextStyle(
                                                  fontFamily: 'Slab',
                                                  fontSize: 32),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),
                  ),
                  dropdownValue.contains('ทั่วโลก')
                      ? Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Container(
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.mood_bad,
                                              size: 35,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              ' ผู้ติดเชื้อทั้งหมด',
                                              style: TextStyle(
                                                  fontFamily: 'Slab',
                                                  fontSize: 28,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? format.format(covidWorld
                                                          .results[0]
                                                          .totalDeaths +
                                                      covidWorld.results[0]
                                                          .totalRecovered +
                                                      covidWorld.results[0]
                                                          .totalUnresolved) +
                                                  ' ราย'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 38,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? 'วันนี้ติดเพิ่ม ${format.format(covidWorld.results[0].totalNewCasesToday)} ราย'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontSize: 28,
                                              color: Colors.lightGreen[300]),
                                        ),
                                      ],
                                    )),
                                margin: EdgeInsets.all(10),
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent[700],
                                    //border: Border.all(),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 7,
                                          spreadRadius: 3,
                                          color: Colors.black54)
                                    ]),
                              ),
                              Container(
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.sentiment_very_dissatisfied,
                                              size: 35,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              ' เสียชี��ิตแล้ว',
                                              style: TextStyle(
                                                  fontFamily: 'Slab',
                                                  fontSize: 34,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? format.format(covidWorld
                                                      .results[0].totalDeaths) +
                                                  ' ราย'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 38,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? '≈ ${(covidWorld.results[0].totalDeaths / (covidWorld.results[0].totalDeaths + covidWorld.results[0].totalRecovered + covidWorld.results[0].totalUnresolved) * 100).toStringAsFixed(2)}%'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontSize: 27,
                                              color: Colors.lightGreen[300]),
                                        ),
                                      ],
                                    )),
                                margin: EdgeInsets.all(10),
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.pinkAccent[100],
                                    //border: Border.all(),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 7,
                                          spreadRadius: 3,
                                          color: Colors.black54)
                                    ]),
                              ),
                              Container(
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.hotel,
                                              size: 35,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              ' รักษาตัว',
                                              style: TextStyle(
                                                  fontFamily: 'Slab',
                                                  fontSize: 34,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? format.format(covidWorld
                                                      .results[0]
                                                      .totalUnresolved) +
                                                  ' ราย'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 38,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? '≈ ${(covidWorld.results[0].totalUnresolved / (covidWorld.results[0].totalDeaths + covidWorld.results[0].totalRecovered + covidWorld.results[0].totalUnresolved) * 100).toStringAsFixed(2)}%'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontSize: 27,
                                              color: Colors.lightGreen[300]),
                                        ),
                                      ],
                                    )),
                                margin: EdgeInsets.all(10),
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.redAccent[200],
                                    //border: Border.all(),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 7,
                                          spreadRadius: 3,
                                          color: Colors.black54)
                                    ]),
                              ),
                              Container(
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.mood,
                                              size: 35,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              ' หายแล้ว',
                                              style: TextStyle(
                                                  fontFamily: 'Slab',
                                                  fontSize: 34,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? format.format(covidWorld
                                                      .results[0]
                                                      .totalRecovered) +
                                                  ' ราย'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 38,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          covidWorld != null
                                              ? '≈ ${(covidWorld.results[0].totalRecovered / (covidWorld.results[0].totalDeaths + covidWorld.results[0].totalRecovered + covidWorld.results[0].totalUnresolved) * 100).toStringAsFixed(2)}%'
                                              : 'Error',
                                          style: TextStyle(
                                              fontFamily: 'Slab',
                                              fontSize: 27,
                                              color: Colors.lightGreen[300]),
                                        ),
                                      ],
                                    )),
                                margin: EdgeInsets.all(10),
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.orange[500],
                                    //border: Border.all(),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 5),
                                          blurRadius: 7,
                                          spreadRadius: 3,
                                          color: Colors.black54)
                                    ]),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              )
            : Center(
                child: Container(
                    width: 100,
                    height: 100,
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text('\nกำลังโหลดข้อมูล'),
                      ],
                    )),
              ),
        PageView.builder(
            pageSnapping: false,
            scrollDirection: Axis.horizontal,
            itemCount: livefeed.livefeed.feeds.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Scaffold(
                                    body: SafeArea(
                                      child: WebView(
                                        initialUrl:
                                            //'https://www.google.com',
                                            livefeed.livefeed.feeds[index].link
                                                .toString(),
                                        javascriptMode:
                                            JavascriptMode.unrestricted,
                                      ),
                                    ),
                                  )));
                    },
                    child: LimitedBox(
                      maxHeight: MediaQuery.of(context).size.height / 2.3,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.network(
                              livefeed.livefeed.feeds[index].pictureURL
                                  .toString(),
                            ).image,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(livefeed.livefeed.feeds[index].details,
                          style: TextStyle(fontFamily: 'Slab', fontSize: 24)),
                    ),
                  ),
                ],
              );
            })
      ],
    );
  }

  Widget build(BuildContext context) {
    return BlocProvider<ImgfeedBloc>(
        create: (context) => _imgfeedBlock,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.pink,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        size: 22,
                      ),
                      onPressed: () async {
                        final FirebaseAuth _firebaseAuth =
                            FirebaseAuth.instance;
                        await _firebaseAuth.signOut().then((value) =>
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage())));
                      }),
                  Text(
                    'user: $user',
                    style: TextStyle(
                        fontFamily: 'Slab',
                        fontSize: 16,
                        fontWeight: FontWeight.w100),
                  ),
                ],
              ),
            ),
          ),
          body: Stack(children: [
            pageView(context),
            AnimatedCrossFade(
              firstCurve: Curves.easeIn,
              secondCurve: Curves.easeInOut,
              crossFadeState: currentPage == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 400),
              firstChild: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      alignment: Alignment.topCenter,
                      //width: 300,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.pink[300]),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: DropdownButton<String>(
                            underline: new Container(),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            value: dropdownValue,
                            icon: Icon(Icons.my_location, color: Colors.white),
                            iconSize: 28,
                            elevation: 40,
                            style: TextStyle(color: Colors.white),
                            onChanged: (String newValue) {
                              //test

                              setState(() {
                                dropdownValue = newValue;
                              });
                              getWorldCovid();
                            },
                            items: <dynamic>[
                              'สถานการณ์ทั่วโลก',
                              'ประเทศไทย',
                              'ประเทศอเมริกา',
                              'ประเทศญี่ปุ่น',
                              'ประเทศอินเดีย',
                              'ประเทศจีน',
                              'ประเทศบราซิล',
                              'ประเทศรัสเซีย',
                              'ประเทศเยอรมัน',
                            ].map<DropdownMenuItem<String>>((dynamic value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      fontFamily: 'Slab',
                                      fontSize: 22,
                                      color: Colors.black),
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                  ),
                ],
              ),
              secondChild: Container(
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: 1,
                color: Colors.transparent,
              ),
            ),
            dropdownValue.contains('ทั่วโลก')
                ? Container()
                : Container(
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          child: Icon(
                            Icons.sentiment_very_dissatisfied,
                            size: 40,
                          ),
                          heroTag: '1',
                          backgroundColor: green ? Colors.green : Colors.grey,
                          onPressed: () {
                            green ? green = false : green = true;
                            if (green)
                              _imgfeedBlock.add(ImgfeedEvent.add(
                                  countryData,
                                  charts.Series(
                                    data: countryData,
                                    colorFn: (datum, index) => charts
                                        .MaterialPalette.green.shadeDefault,
                                    domainFn: (TimelineData data, index) =>
                                        data.day,
                                    measureFn: (TimelineData data, index) =>
                                        data.newDeaths,
                                    labelAccessorFn: (TimelineData data,
                                            index) =>
                                        '${data.newDeaths} : ${format.format(data.newCases)} ราย',
                                    id: 'ตายรายใหม่',
                                  )));
                              else
                                _imgfeedBlock.add(ImgfeedEvent.delete("ตายรายใหม่"));
                            //setUpLine();
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        FloatingActionButton(
                          child: Icon(Icons.mood_bad, size: 40),
                          heroTag: '2',
                          backgroundColor:
                              red ? Colors.deepOrange : Colors.grey,
                          onPressed: () {
                            var a = charts.Series(
                              data: countryData,
                              colorFn: (datum, index) => charts
                                  .MaterialPalette.deepOrange.shadeDefault,
                              domainFn: (TimelineData data, index) => data.day,
                              measureFn: (TimelineData data, index) =>
                                  data.totalCases,
                              labelAccessorFn: (TimelineData data, index) =>
                                  '${data.newDeaths} : ${format.format(data.newCases)} ราย',
                              id: 'ติดเชื้อ',
                            );
                            if (!red) {
                              //print('false');
                              _imgfeedBlock
                                  .add(ImgfeedEvent.add(countryData, a));
                            } else {
                              //print('true');
                              _imgfeedBlock
                                  .add(ImgfeedEvent.delete("ติดเชื้อ"));
                            }
                            //setUpLine();
                            red ? red = false : red = true;
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        FloatingActionButton(
                          child: Icon(Icons.sentiment_dissatisfied, size: 40),
                          heroTag: '3',
                          backgroundColor: blue ? Colors.blue : Colors.grey,
                          onPressed: () {
                            blue ? blue = false : blue = true;
                            //setUpLine();
                            if (blue)
                              _imgfeedBlock.add(ImgfeedEvent.add(
                                  countryData,
                                  charts.Series(
                                    data: countryData,
                                    colorFn: (datum, index) => charts
                                        .MaterialPalette.blue.shadeDefault,
                                    domainFn: (TimelineData data, index) =>
                                        data.day,
                                    measureFn: (TimelineData data, index) =>
                                        data.newCases,
                                    labelAccessorFn: (TimelineData data,
                                            index) =>
                                        '${data.newDeaths} : ${format.format(data.newCases)} ราย',
                                    id: 'ติดเชื้อรายใหม่',
                                  )));
                            else {
                              _imgfeedBlock
                                  .add(ImgfeedEvent.delete("ติดเชื้อรายใหม่"));
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
          ]),
        ));
  }
}
