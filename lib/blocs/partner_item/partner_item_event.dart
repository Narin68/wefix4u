part of 'partner_item_bloc.dart';

@immutable
abstract class PartnerItemEvent {
  List<Object> get props => [];
}

@immutable
class FetchPartnerItem extends PartnerItemEvent {
  final int? records;
  final bool? isInit;

  FetchPartnerItem({this.records = 15, this.isInit});

  @override
  List<Object> get props => [];
}

class ReloadItem extends PartnerItemEvent {
  final String search;

  ReloadItem({this.search = ''});

  @override
  List<Object> get props => [this.search];
}

class UpdateItem extends PartnerItemEvent {
  final MPartnerServiceItemData data;

  UpdateItem({required this.data});

  @override
  List<Object> get props => [data];
}

class DeleteItem extends PartnerItemEvent {
  final int id;

  DeleteItem({required this.id});

  @override
  List<Object> get props => [id];
}
