import 'package:demo/controllers/item_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddItem extends HookWidget {
  static const route = '/addItem';
  const AddItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textContoroller = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: textContoroller,
              autocorrect: true,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Add Item'),
            ),
            ElevatedButton(
                onPressed: () {
                  context
                      .read(itemListControllerProvider)
                      .addItem(name: textContoroller.text.trim());
                },
                child: Text('Add Item'))
          ],
        ),
      ),
    );
  }
}
