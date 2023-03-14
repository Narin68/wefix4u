part of 'settlement_rule_cubit.dart';

@immutable
abstract class SettlementRuleState {
  List<Object> get props => [];
}

class SettlementRuleInitial extends SettlementRuleState {
  @override
  List<Object> get props => [];
}

class SettlementRuleLoading extends SettlementRuleState {
  @override
  List<Object> get props => [];
}

class SettlementRuleSuccess extends SettlementRuleState {
  final MSettlementData? data;

  SettlementRuleSuccess({this.data});

  SettlementRuleSuccess copyWith({
    MSettlementData? data,
  }) =>
      SettlementRuleSuccess(
        data: data ?? this.data,
      );

  @override
  List<Object> get props => [data!];
}

class SettlementRuleFailure extends SettlementRuleState {
  final String message;
  final int statusCode;

  SettlementRuleFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
