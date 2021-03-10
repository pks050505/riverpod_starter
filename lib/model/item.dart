import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
abstract class Item implements _$Item {
  const Item._();
  const factory Item({
    String? id,
    required String name,
    @Default(false) bool obtained,
  }) = _Item;
  factory Item.empty() => Item(name: '');
  factory Item.fromDocument(DocumentSnapshot snap) {
    var data = snap.data()!;
    return Item.fromJson(data).copyWith(id: snap.id);
  }
  Map<String, dynamic> toDocument() => toJson()..remove('id');
  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
