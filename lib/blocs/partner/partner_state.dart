part of 'partner_cubit.dart';

@immutable
abstract class PartnerState {
  List<Object> get props => [];
}

class PartnerInitial extends PartnerState {
  @override
  List<Object> get props => [];
}

class PartnerLoading extends PartnerState {
  @override
  List<Object> get props => [];
}

class PartnerSuccess extends PartnerState {
  final List<MPartnerRequest>? data;
  final MPartnerRequestDetail? detail;
  final MPartner? partnerData;

  PartnerSuccess({this.data, this.detail, this.partnerData});

  PartnerSuccess copyWith({
    List<MPartnerRequest>? data,
    MPartnerRequestDetail? detail,
    MPartner? partnerData,
  }) =>
      PartnerSuccess(
        data: data ?? this.data,
        detail: detail ?? this.detail,
        partnerData: partnerData ?? this.partnerData,
      );

  @override
  List<Object> get props => [data!, partnerData!, detail!];
}

class PartnerFailure extends PartnerState {
  final String message;
  final int statusCode;

  PartnerFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
