import 'package:audioplayers/audioplayers.dart';
const String url ="https://data.chiasenhac.com/downloads/2037/1/2036425/320/Co%20tat%20ca%20nhung%20khong%20co%20anh%20-%20Erik.mp3";
AudioPlayer audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
play() async {
  
 int i = await audioPlayer.play(url,isLocal: false);
 print(i);
}
