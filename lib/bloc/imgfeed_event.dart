import 'package:charts_flutter/flutter.dart';
import 'package:cowith19/covid.dart';
//part of 'imgfeed_bloc.dart';

enum EventType { add, delete }

class ImgfeedEvent {
  List<TimelineData> countryData;
  Series<TimelineData, int> chart;
  EventType eventType;
  String id;

  ImgfeedEvent.add(
      List<TimelineData> countryData, Series<TimelineData, int> chart) {
    this.countryData = countryData;
    this.chart = chart;
    this.eventType = EventType.add;
  }

  ImgfeedEvent.delete(String index) {
    this.id = index;
    this.eventType = EventType.delete;
  }
}
