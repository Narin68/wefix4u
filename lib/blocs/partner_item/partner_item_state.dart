part of 'partner_item_bloc.dart';

@immutable
abstract class PartnerItemState {
  List<Object> get props => [];
}

class PartnerItemInitial extends PartnerItemState {
  @override
  List<Object> get props => [];
}

class PartnerItemLoading extends PartnerItemState {
  @override
  List<Object> get props => [];
}

class PartnerItemSuccess extends PartnerItemState {
  final List<MPartnerServiceItemData>? data;
  final bool? hasMax;

  PartnerItemSuccess({this.data, this.hasMax});

  copyWith({
    List<MPartnerServiceItemData>? data,
    bool? hasMax,
  }) =>
      PartnerItemSuccess(
        data: data ?? this.data,
        hasMax: hasMax ?? this.hasMax,
      );

  @override
  List<Object> get props => [data!, hasMax!];
}

class PartnerItemFailure extends PartnerItemState {
  final String message;
  final int statusCode;

  PartnerItemFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
