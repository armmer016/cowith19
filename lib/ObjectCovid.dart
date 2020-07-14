// To parse this JSON data, do
//
//     final objectCovid = objectCovidFromJson(jsonString);

import 'dart:convert';

ObjectCovid objectCovidFromJson(String str) =>
    ObjectCovid.fromJson(json.decode(str));

String objectCovidToJson(ObjectCovid data) => json.encode(data.toJson());

class ObjectCovid {
  ObjectCovid({
    this.results,
    this.stat,
  });

  List<Result> results;
  String stat;

  factory ObjectCovid.fromJson(Map<String, dynamic> json) => ObjectCovid(
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        stat: json["stat"],
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "stat": stat,
      };
}

class Result {
  Result({
    this.totalCases,
    this.totalRecovered,
    this.totalUnresolved,
    this.totalDeaths,
    this.totalNewCasesToday,
    this.totalNewDeathsToday,
    this.totalActiveCases,
    this.totalSeriousCases,
    this.totalAffectedCountries,
    this.source,
  });

  int totalCases;
  int totalRecovered;
  int totalUnresolved;
  int totalDeaths;
  int totalNewCasesToday;
  int totalNewDeathsToday;
  int totalActiveCases;
  int totalSeriousCases;
  int totalAffectedCountries;
  Source source;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        totalCases: json["total_cases"],
        totalRecovered: json["total_recovered"],
        totalUnresolved: json["total_unresolved"],
        totalDeaths: json["total_deaths"],
        totalNewCasesToday: json["total_new_cases_today"],
        totalNewDeathsToday: json["total_new_deaths_today"],
        totalActiveCases: json["total_active_cases"],
        totalSeriousCases: json["total_serious_cases"],
        totalAffectedCountries: json["total_affected_countries"],
        source: Source.fromJson(json["source"]),
      );

  Map<String, dynamic> toJson() => {
        "total_cases": totalCases,
        "total_recovered": totalRecovered,
        "total_unresolved": totalUnresolved,
        "total_deaths": totalDeaths,
        "total_new_cases_today": totalNewCasesToday,
        "total_new_deaths_today": totalNewDeathsToday,
        "total_active_cases": totalActiveCases,
        "total_serious_cases": totalSeriousCases,
        "total_affected_countries": totalAffectedCountries,
        "source": source.toJson(),
      };
}

class Source {
  Source({
    this.url,
  });

  String url;

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}
