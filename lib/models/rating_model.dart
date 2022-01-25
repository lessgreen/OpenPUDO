import 'package:json_annotation/json_annotation.dart';

part 'rating_model.g.dart';

@JsonSerializable()
class RatingModel {
  int pudoId;
  int averageScore;
  int reviewCount;

  RatingModel({
    required this.pudoId,
    required this.averageScore,
    required this.reviewCount
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);
}