import 'package:youtube_player_iframe/youtube_player_iframe.dart';

String? extractYoutubeVideoId(String url) =>
    YoutubePlayerController.convertUrlToId(url);
