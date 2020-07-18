import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:charts_flutter/flutter.dart';
import 'imgfeed_event.dart';
import 'imgfeed_state.dart';
import 'package:cowith19/covid.dart';
import 'package:meta/meta.dart';

// part 'imgfeed_event.dart';
// part 'imgfeed_state.dart';

class ImgfeedBloc extends Bloc<ImgfeedEvent, List<Series<TimelineData, int>>> {
  ImgfeedBloc() : super(List<Series<TimelineData, int>>());
  List<Series<TimelineData, int>> get initialState =>
      List<Series<TimelineData, int>>();
  @override
  Stream<List<Series<TimelineData, int>>> mapEventToState(
    ImgfeedEvent event,
  ) async* {
    switch (event.eventType) {
      case EventType.add:
        List<Series<TimelineData, int>> newState = List.from(state);
        if (event.chart != null && !newState.contains(event.chart)) {
          
          newState.add(event.chart);
        }
        yield newState;
        break;
      case EventType.delete:
        List<Series<TimelineData, int>> newState = List.from(state);
        //print(newState[0]);
        newState.removeWhere((element) => element.id == event.id);
        //print('2'+newState[0].toString());
        yield newState;
        break;
      default:
        throw Exception('Error');
    }
  }
}
