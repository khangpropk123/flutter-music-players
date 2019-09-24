import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'MediaPlayer.dart';
import 'package:audioplayers/audioplayers.dart';

class Player extends StatefulWidget {
  Player({Key key}) : super(key: key);
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  AnimationController pageController;
  AnimationController playerController;
  Animation pageAnimation;

  //AnimationController bgController;
  Animation bgAnimation;
  Animation blurAnimation;
  Animation songColorAnimation;
  Animation nowPlayingColorAnimation;
  Animation nowPlayingSizeAnimation;
  Animation nowPlayingSizeButtonAnimation;
  Animation nowPlayingSliderColorAnimation;
  Animation sliderPlayerAnimation;

  AudioPlayer audioPlayer;

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  Duration _duration;
  Duration _position;

  bool isTop = false;
  bool isPlaying = false;
  bool isLoading = false;
  double total_time;
  double now_time;
  double left_time;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    total_time = 100;
    now_time = 0;
    left_time = total_time;
    pageController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    playerController =
        AnimationController(vsync: this, duration: Duration(seconds: 100));
    pageAnimation = Tween<double>(begin: -250.0, end: 0.0).animate(
        CurvedAnimation(parent: pageController, curve: Curves.easeInBack));
    bgAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
        CurvedAnimation(parent: pageController, curve: Curves.easeInBack));
    blurAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
        CurvedAnimation(parent: pageController, curve: Curves.easeInBack));
    songColorAnimation =
        ColorTween(begin: Colors.black87, end: Colors.white.withOpacity(0.5))
            .animate(pageController);
    nowPlayingColorAnimation =
        ColorTween(begin: Colors.white.withOpacity(0.5), end: Colors.black87)
            .animate(pageController);
    nowPlayingSizeAnimation =
        Tween<double>(begin: 15, end: 20).animate(pageController);
    nowPlayingSizeButtonAnimation =
        Tween<double>(begin: 24, end: 40).animate(pageController);
    nowPlayingSliderColorAnimation = ColorTween(
            begin: CupertinoColors.activeOrange,
            end: CupertinoColors.activeGreen)
        .animate(pageController);
    sliderPlayerAnimation =
        Tween<double>(begin: 0, end: 100).animate(playerController);
    audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    initPlayer();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  play() async {
    setState(() {
      isLoading = true;
    });
    const String url =
        "https://data.chiasenhac.com/downloads/2037/2/2036425/320/Co%20tat%20ca%20nhung%20khong%20co%20anh%20-%20Erik.mp3";
    int i = await audioPlayer.play(url, isLocal: false);
    if (i == 1)
      setState(() {
        isPlaying = !isPlaying;
        isLoading = false;
      });
  }

  pause() async {
    int i = await audioPlayer.pause();
    if (i == 1)
      setState(() {
        isPlaying = !isPlaying;
      });
  }

  initAnimate() {
    if (isTop) {
      pageController.reverse();
    } else {
      pageController.forward();
    }
    isTop = !isTop;
  }

  initPlayer() {
    _durationSubscription =
        audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {});
    });
  }

  playerAnimate() {
    if (isPlaying) {
      playerController.forward();
    } else {
      playerController.stop();
    }
  }

  String standartTime(double time) {
    int iTime = time.round();
    int mm, ss;
    mm = (iTime / 60).floor();
    ss = iTime - mm * 60;
    String s;
    if (ss < 10) {
      s = "0" + ss.toString();
    } else {
      s = ss.toString();
    }
    return mm.toString() + ":" + s;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (BuildContext context, widget) {
        return isLoading
            ? CircularProgressIndicator()
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  FractionallySizedBox(
                    heightFactor: bgAnimation.value,
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: ExactAssetImage('assets/bg.jpg'),
                        fit: BoxFit.cover,
                      )),
                      height: MediaQuery.of(context).size.height,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: blurAnimation.value,
                            sigmaY: blurAnimation.value),
                        child: Container(
                          color: Colors.white.withOpacity(0.0),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: pageAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        initAnimate();
                        print(standartTime(121.4));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: songColorAnimation.value,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25))),
                        alignment: Alignment.bottomCenter,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text("Now Playing",
                                  style: prefix0.TextStyle(
                                      color: nowPlayingColorAnimation.value,
                                      fontSize: nowPlayingSizeAnimation.value,
                                      fontStyle: FontStyle.italic)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "We Don't Talk Anymore (feat. Selena Gomez)",
                                style: prefix0.TextStyle(
                                  fontSize: 16,
                                  color: nowPlayingColorAnimation.value,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 1.0),
                              child: Text(
                                "Selena Gomez, Charlie Puth, Jacob Kasher",
                                style: prefix0.TextStyle(
                                  fontSize: 12,
                                  color: nowPlayingColorAnimation.value,
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 0, left: 20, right: 20),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: AnimatedBuilder(
                                      animation: playerController,
                                      builder: (BuildContext context, widget) {
                                        return Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                standartTime(_position == null
                                                    ? 0.0
                                                    : _position.inSeconds
                                                        .toDouble()),
                                                style: prefix0.TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      nowPlayingColorAnimation
                                                          .value,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: CupertinoSlider(
                                                activeColor:
                                                    nowPlayingSliderColorAnimation
                                                        .value,
                                                onChanged: (value) {
                                                  final Position = value *
                                                      _duration.inMilliseconds;
                                                  print(value);
                                                  audioPlayer.seek(Duration(
                                                      milliseconds:
                                                          Position.round()));
                                                },
                                                value: (_position != null &&
                                                        _duration != null &&
                                                        _position
                                                                .inMilliseconds >
                                                            0 &&
                                                        _position
                                                                .inMilliseconds <
                                                            _duration
                                                                .inMilliseconds)
                                                    ? _position.inMilliseconds /
                                                        _duration.inMilliseconds
                                                    : 0.0,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                standartTime(_duration == null
                                                    ? 0
                                                    : _duration.inSeconds
                                                            .toDouble() -
                                                        _position.inSeconds
                                                            .toDouble()),
                                                style: prefix0.TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      nowPlayingColorAnimation
                                                          .value,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                )),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Icon(
                                        Icons.skip_previous,
                                        color: nowPlayingColorAnimation.value,
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (isPlaying)
                                            pause();
                                          else
                                            play();
                                        },
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: nowPlayingColorAnimation.value,
                                          size: nowPlayingSizeButtonAnimation
                                              .value,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(Icons.skip_next,
                                          color:
                                              nowPlayingColorAnimation.value),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 2.4,
                              child: ListView.builder(
                                itemCount: 30,
                                itemBuilder: (BuildContext context, index) {
                                  return Row(
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ListTile(
                                          title: Text(
                                            "We Don't Talk Anymore (feat. Selena Gomez)",
                                            style: prefix0.TextStyle(
                                              fontSize: 12,
                                              color: nowPlayingColorAnimation
                                                  .value,
                                            ),
                                          ),
                                          leading: Container(
                                            child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  'assets/song_img.jpeg'),
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Selena Gomez, Charlie Puth, Jacob Kasher",
                                            style: prefix0.TextStyle(
                                              fontSize: 9,
                                              color: nowPlayingColorAnimation
                                                  .value,
                                            ),
                                          ),
                                          trailing: Text("3:20",
                                              style: prefix0.TextStyle(
                                                fontSize: 11,
                                                color: nowPlayingColorAnimation
                                                    .value,
                                              )),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
