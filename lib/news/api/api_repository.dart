import 'dart:async';

import 'package:multibox/news/api/api_provider.dart';
import 'package:multibox/news/model/topheadlinesnews/response_top_headlinews_news.dart';

class ApiRepository {
  final _apiProvider = ApiProvider();

  Future<ResponseTopHeadlinesNews> fetchTopHeadlinesNews() =>
      _apiProvider.getTopHeadlinesNews();

  Future<ResponseTopHeadlinesNews> fetchTopBusinessHeadlinesNews() =>
      _apiProvider.getTopBusinessHeadlinesNews();

  Future<ResponseTopHeadlinesNews> fetchTopEntertainmentHeadlinesNews() =>
      _apiProvider.getTopEntertainmentHeadlinesNews();

  Future<ResponseTopHeadlinesNews> fetchTopHealthHeadlinesNews() =>
      _apiProvider.getTopHealthHeadlinesNews();

  Future<ResponseTopHeadlinesNews> fetchTopScienceHeadlinesNews() =>
      _apiProvider.getTopScienceHeadlinesNews();

  Future<ResponseTopHeadlinesNews> fetchTopSportHeadlinesNews() =>
      _apiProvider.getTopSportHeadlinesNews();

  Future<ResponseTopHeadlinesNews> fetchTopTechnologyHeadlinesNews() =>
      _apiProvider.getTopTechnologyHeadlinesNews();
}
