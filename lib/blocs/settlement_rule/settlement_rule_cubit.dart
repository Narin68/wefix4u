import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/globals.dart';
import '/modals/settlement_rule.dart';
import '/repositories/settlement.dart';

part 'settlement_rule_state.dart';

class SettlementRuleCubit extends Cubit<SettlementRuleState> {
  SettlementRuleCubit() : super(SettlementRuleInitial());
  var _repo = SettlementRuleRepo();

  Future getSettlementRule() async {
    emit(SettlementRuleLoading());
    var _res = await _repo.getByRefId(refId: Model.partner.id ?? 0);

    if (_res.error && _res.statusCode == 50503) {
      var _result =
          await _repo.getList(MSettlementFilter(refId: 0,));
      // refId 0 when partner don't have settlement rule
      if (!_result.error) {
        if (_result.data.isNotEmpty) {
          Model.settlementRule = _result.data[0];
          emit(SettlementRuleSuccess(data: _result.data[0]));
        }
      } else {
        emit(
          SettlementRuleFailure(
            statusCode: _result.statusCode,
            message: _result.message,
          ),
        );
      }
    } else if (!_res.error) {
      Model.settlementRule = _res.data;
      emit(SettlementRuleSuccess(data: _res.data));
    } else {
      emit(SettlementRuleFailure(
          statusCode: _res.statusCode, message: _res.message));
    }
  }

  Future updateSettlementRule(MSettlementData data) async {
    Model.settlementRule = data;
    emit(SettlementRuleSuccess(data: data));
  }
}
