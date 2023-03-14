import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/globals.dart';
import '/modals/partner.dart';
import '/repositories/partner_repo.dart';

part 'partner_state.dart';

class PartnerCubit extends Cubit<PartnerState> {
  PartnerCubit() : super(PartnerInitial());
  var _repo = PartnerRepo();

  Future getPartnerRequest(int? cusId) async {
    emit(PartnerLoading());
    var result = await _repo.getPartnerRequest(cusId);
    if (!result.error) {
      emit(PartnerSuccess(
        data: result.data,
      ));
    } else
      emit(PartnerFailure(
          statusCode: result.statusCode, message: result.message));
  }

  Future getPartnerRequestDetail(MPartnerRequest data) async {
    emit(PartnerLoading());

    var _res = await _repo.getRequestPartnerDetail(data.id);
    if (!_res.error) {
      emit(PartnerSuccess(data: [data], detail: _res.data));
    } else {
      emit(PartnerFailure(message: _res.message, statusCode: _res.statusCode));
    }
  }

  Future getPartnerDetail() async {
    emit(PartnerLoading());
    var _res = await _repo.getPartnerDetail(Model.partner.id);
    if (!_res.error) {
      emit(PartnerSuccess()
          .copyWith(detail: _res.data, partnerData: Model.partner));
    } else {
      emit(PartnerFailure(message: _res.message, statusCode: _res.statusCode));
    }
  }

  Future update(
      {MPartner? partner,
      MPartnerRequestDetail? detail,
      List<MPartnerRequest>? data}) async {
    if (partner != null) await PartnerRepo.savePartnerToPref(partner);
    emit(
        PartnerSuccess(detail: detail, partnerData: partner, data: data ?? []));
  }
}
