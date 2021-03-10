import 'package:demo/controllers/auth_controller.dart';
import 'package:demo/exceptions/custom_exception.dart';
import 'package:demo/model/item.dart';
import 'package:demo/repositorys/item_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final itemListControllerProvider =
    StateNotifierProvider<ItemListController>((ref) {
  final user = ref.watch(authControllerProvider.state);
  return ItemListController(ref.read, user?.uid);
});
final itemListExceptionProvider = StateProvider<CustomException?>((_) => null);

class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  final Reader _read;
  final String? _userId;
  ItemListController(this._read, this._userId) : super(AsyncValue.loading()) {
    if (_userId != null) {
      retrieveItem();
    }
  }
  Future<void> retrieveItem({bool isRefreshing = false}) async {
    if (isRefreshing) state = AsyncValue.loading();
    try {
      final items =
          await _read(itemRepositoryProvider).retrieveItems(userId: _userId!);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } on CustomException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem({required String name, bool obtained = false}) async {
    try {
      final Item item = Item(name: name, obtained: obtained);
      final String itemId = await _read(itemRepositoryProvider)
          .createItem(userId: _userId!, item: item);
      state.whenData((items) =>
          state = AsyncValue.data(items..add(item.copyWith(id: itemId))));
    } on CustomException catch (e) {
      _read(itemListExceptionProvider).state = e;
    }
  }

  Future<void> updateItem({required Item updatedItem}) async {
    try {
      await _read(itemRepositoryProvider)
          .updateItem(userId: _userId!, item: updatedItem);
      state.whenData((items) {
        state = AsyncValue.data([
          for (final item in items)
            if (item.id == updatedItem.id) updatedItem else item
        ]);
      });
    } on CustomException catch (e) {
      _read(itemListExceptionProvider).state = e;
    }
  }

  Future<void> deleteItem({required String itemId}) async {
    try {
      await _read(itemRepositoryProvider)
          .deleteItem(userId: _userId!, itemId: itemId);
      state.whenData((items) =>
          state = AsyncValue.data(items..removeWhere((e) => e.id == itemId)));
    } on CustomException catch (e) {
      _read(itemListExceptionProvider).state = e;
    }
  }
}
