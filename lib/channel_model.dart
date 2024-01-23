// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChannelModel {
  final String uid;
  final String music;
  final bool play;
  final int min;
  ChannelModel({
    required this.uid,
    required this.music,
    required this.play,
    required this.min,
  });

  ChannelModel copyWith({
    String? uid,
    String? music,
    bool? play,
    int? min,
  }) {
    return ChannelModel(
      uid: uid ?? this.uid,
      music: music ?? this.music,
      play: play ?? this.play,
      min: min ?? this.min,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'music': music,
      'play': play,
      'min': min,
    };
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      uid: map['uid'] as String,
      music: map['music'] as String,
      play: map['play'] as bool,
      min: map['min'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChannelModel.fromJson(String source) => ChannelModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChannelModel(uid: $uid, music: $music, play: $play, min: $min)';
  }

  @override
  bool operator ==(covariant ChannelModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.music == music &&
      other.play == play &&
      other.min == min;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      music.hashCode ^
      play.hashCode ^
      min.hashCode;
  }
}
