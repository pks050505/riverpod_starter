import 'package:demo/controllers/auth_controller.dart';
import 'package:demo/controllers/item_list_controller.dart';
import 'package:demo/exceptions/custom_exception.dart';
import 'package:demo/model/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final userControllerState = useProvider(authControllerProvider.state);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        leading: userControllerState != null
            ? IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => context.read(authControllerProvider).signOut(),
              )
            : null,
      ),
      body: ProviderListener(
        provider: itemListExceptionProvider,
        onChange: (context, StateController<CustomException?> exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 20),
              // content: SelectText(exception.state!.toString()),
              content: SelectableText(exception.state!.toString()),
            ),
          );
        },
        child: const ItemList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddItemDialog.show(context, Item.empty());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddItemDialog extends HookWidget {
  final Item item;

  static void show(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(item: item),
    );
  }

  const AddItemDialog({Key? key, required this.item}) : super(key: key);
  bool get isUpdating => item.id != null;
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: item.name);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: textController,
              decoration: const InputDecoration(hintText: 'Item name'),
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: isUpdating
                        ? Colors.purple
                        : Theme.of(context).primaryColor),
                onPressed: () {
                  isUpdating
                      ? context.read(itemListControllerProvider).updateItem(
                            updatedItem: item.copyWith(
                                name: textController.text.trim(),
                                obtained: item.obtained),
                          )
                      : context
                          .read(itemListControllerProvider)
                          .addItem(name: textController.text.trim());
                  Navigator.of(context).pop();
                },
                child: Text(isUpdating ? 'Update' : 'Add'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

final currentItem = ScopedProvider<Item>((_) => throw UnimplementedError());

class ItemList extends HookWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemListState = useProvider(itemListControllerProvider.state);
    return Container(
      child: itemListState.when(
          data: (items) => items.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      const Text('Once you start adding item will shown here'),
                      const SizedBox(height: 20),
                      const Text('Tab + to add item')
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, int i) {
                    final item = items[i];
                    return ProviderScope(
                      overrides: [currentItem.overrideWithValue(item)],
                      child: const ItemTile(),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ItemListError(
                message: 'something went wrong',
                // message: error is CustomException
                //     ? error.message!
                //     : 'Something went wrong!',
              )),
    );
  }
}

class ItemListError extends HookWidget {
  final String? message;
  const ItemListError({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message!,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context
                .read(itemListControllerProvider)
                .retrieveItem(isRefreshing: true),
            child: Text('retry'),
          )
        ],
      ),
    );
  }
}

class ItemTile extends HookWidget {
  const ItemTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = useProvider(currentItem);
    return ListTile(
      key: ValueKey(item.id),
      title: Text(item.name),
      trailing: Checkbox(
        value: item.obtained,
        onChanged: (val) => context.read(itemListControllerProvider).updateItem(
              updatedItem: item.copyWith(obtained: !item.obtained),
            ),
      ),
      onTap: () => AddItemDialog.show(context, item),
      onLongPress: () =>
          context.read(itemListControllerProvider).deleteItem(itemId: item.id!),
    );
  }
}
