// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MusicModel {
  final String songname;
  final String songdescription;
  final String downloadUrl;
  MusicModel({
    required this.songname,
    required this.songdescription,
    required this.downloadUrl,
  });
  

  MusicModel copyWith({
    String? songname,
    String? songdescription,
    String? downloadUrl,
  }) {
    return MusicModel(
      songname: songname ?? this.songname,
      songdescription: songdescription ?? this.songdescription,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'songname': songname,
      'songdescription': songdescription,
      'downloadUrl': downloadUrl,
    };
  }

  factory MusicModel.fromMap(Map<String, dynamic> map) {
    return MusicModel(
      songname: map['songname'] as String,
      songdescription: map['songdescription'] as String,
      downloadUrl: map['downloadUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MusicModel.fromJson(String source) => MusicModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MusicModel(songname: $songname, songdescription: $songdescription, downloadUrl: $downloadUrl)';

  @override
  bool operator ==(covariant MusicModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.songname == songname &&
      other.songdescription == songdescription &&
      other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode => songname.hashCode ^ songdescription.hashCode ^ downloadUrl.hashCode;
}
