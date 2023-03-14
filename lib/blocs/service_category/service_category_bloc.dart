import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/service_category.dart';
import '/repositories/service_category.dart';

part 'service_category_event.dart';

part 'service_category_state.dart';

class ServiceCategoryBloc
    extends Bloc<ServiceCategoryEvent, ServiceCategoryState> {
  final ServiceCateRepo repo = ServiceCateRepo();

  ServiceCategoryBloc() : super(ServiceCategoryInitial()) {
    on(_init);
  }

  Future<void> _init(
      ServiceCategoryEvent event, Emitter<ServiceCategoryState> emit) async {
    var _currState = state;
    int _record = 100;

    if (event is ReloadServiceCate) {
      emit(ServiceCategoryInitial());
    }

    if (event is FetchServiceCate && !_hasReachedMax(_currState)) {
      if ((event.isInit ?? false) && _currState is ServiceCategorySuccess) {
        return;
      }

      /// init data
      if (_currState is ServiceCategoryInitial) {
        emit(ServiceCategoryLoading());

        if (event.getNewData) {
          await _getData(emit);
          return;
        }

        List<MServiceCate> prefData = await repo.getCatToPref();

        if (prefData.isNotEmpty) {
          emit(ServiceCategorySuccess(data: prefData));
          await Future.delayed(Duration(seconds: 5));

          var _result = await repo.list(pages: 1, search: '');
          if (!_result.error) {
            repo.saveCatToPref(_result.data);
            if (_result.data.length != prefData.length) {
              emit(ServiceCategorySuccess(data: _result.data));
            }
          }
        } else {
          await _getData(emit);
        }
        return;
      }

      /// Get more data
      if (_currState is ServiceCategorySuccess) {
        int _page = (_currState.data!.length / _record).ceil() + 1;

        var _result = await repo.list(search: '', pages: _page);

        if (!_result.error) {
          emit(ServiceCategorySuccess(data: _result.data));
        } else {
          emit(ServiceCategoryFailure(
              message: "${_result.message}", statusCode: _result.statusCode));
        }
        return;
      }
    }
  }

  Future _getData(Emitter<ServiceCategoryState> emit, {int page = 1}) async {
    var _result = await repo.list(pages: page, search: '');

    if (!_result.error) {
      repo.saveCatToPref(_result.data);
      emit(ServiceCategorySuccess(data: _result.data));
    } else {
      emit(ServiceCategoryFailure(
          message: "${_result.message}", statusCode: _result.statusCode));
    }
  }

  bool _hasReachedMax(ServiceCategoryState state) =>
      state is ServiceCategorySuccess && (state.hasMax ?? false);
}
