import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '/modals/news_and_promotion.dart';
import '/repositories/news_and_promotion.dart';

part 'news_and_promotion_state.dart';

class NewsAndPromotionCubit extends Cubit<NewsAndPromotionState> {
  final NewsAndPromotionRepo repo;

  NewsAndPromotionCubit(this.repo) : super(NewsAndPromotionInitial());

  Future reload() async {
    emit(NewsAndPromotionInitial());
  }

  Future fetch({bool? isInit, isLoading = true}) async {
    if (isInit ?? false) emit(NewsAndPromotionInitial());

    final currState = state;
    final limit = 10;

    if (_hasReachedMax(currState)) return;

    var filter = MNewsAndPromotionFilter(
        pages: 1,
        records: limit,
        orderBy: 'Id',
        orderDir: 'DESC',
        posting: true);

    if (currState is NewsAndPromotionInitial) {
      if (isLoading) emit(NewsAndPromotionLoading());

      final result = await repo.get(filter);

      if (!result.error) {
        List<MNewsAndPromotion> data = result.data;
        emit(NewsAndPromotionSuccess(
          data: data,
          hasReachedMax: data.length < limit,
        ));
      } else {
        emit(NewsAndPromotionFailure(
            statusCode: result.statusCode, message: result.message));
      }

      return;
    }

    /// Load more data
    if (currState is NewsAndPromotionSuccess) {
      filter = filter.copyWith(
          pages: ((currState.data ?? []).length / limit).ceil() + 1);

      final result = await repo.get(filter);

      if (!result.error) {
        List<MNewsAndPromotion> data = result.data;
        emit(data.length == 0
            ? currState.copyWith(hasReachedMax: true)
            : currState.copyWith(
                data: (currState.data ?? []) + data,
                hasReachedMax: data.length < limit,
              ));
      } else {
        emit(NewsAndPromotionFailure(
            statusCode: result.statusCode, message: result.message));
      }
    }
  }

  bool _hasReachedMax(NewsAndPromotionState state) =>
      state is NewsAndPromotionSuccess && (state.hasReachedMax ?? false);
}
