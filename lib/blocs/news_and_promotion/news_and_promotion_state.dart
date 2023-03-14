part of 'news_and_promotion_cubit.dart';

abstract class NewsAndPromotionState extends Equatable {
  const NewsAndPromotionState();
}

class NewsAndPromotionInitial extends NewsAndPromotionState {
  @override
  List<Object> get props => [];
}

class NewsAndPromotionLoading extends NewsAndPromotionState {
  @override
  List<Object> get props => [];
}

class NewsAndPromotionSuccess extends NewsAndPromotionState {
  final List<MNewsAndPromotion>? data;
  final bool? hasReachedMax;

  NewsAndPromotionSuccess({this.data, this.hasReachedMax});

  NewsAndPromotionSuccess copyWith({
    List<MNewsAndPromotion>? data,
    bool? hasReachedMax,
  }) =>
      NewsAndPromotionSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      );

  @override
  List<Object> get props => [data ?? [], hasReachedMax ?? false];
}

class NewsAndPromotionFailure extends NewsAndPromotionState {
  final String message;
  final int statusCode;

  NewsAndPromotionFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
