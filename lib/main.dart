import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class Product {
  String name;

  Product({required this.name});
}

typedef ShoppingListCallback = Function(Product item);
typedef ShoppingListEditCallback = Function(Product item, String newName);

class ShoppingListItem extends StatefulWidget {
  final Product item;
  final bool inCart;
  final ShoppingListCallback toggleInCart;
  final ShoppingListCallback deleteItem;

  const ShoppingListItem(
      {required this.item,
      required this.inCart,
      required this.toggleInCart,
      required this.deleteItem,
      super.key});

  @override
  State<ShoppingListItem> createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  void _onEdit(String newName) {
    setState(() {
      widget.item.name = newName;
    });
  }

  void _submitTextField() {
    String value = _controller.text.trim();
    _controller.text = value;
    _onEdit(value);
  }

  Color _getColour() {
    return widget.inCart ? Colors.black54 : Theme.of(context).primaryColor;
  }

  TextStyle? _getTextStyle() {
    if (!widget.inCart) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  void didUpdateWidget(ShoppingListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      _controller.text = widget.item.name;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.item.name);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection =
            TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      } else {
        _submitTextField();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getColour(),
        child: Text(widget.item.name[0]),
      ),
      title: IgnorePointer(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          style: _getTextStyle(),
          decoration: const InputDecoration(border: InputBorder.none),
          autocorrect: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (String value) {
            _submitTextField();
          },
        ),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _focusNode.requestFocus(),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            widget.deleteItem(widget.item);
          },
        ),
      ]),
      onTap: () {
        widget.toggleInCart(widget.item);
      },
    );
  }
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<Product> shoppingList = [];
  List<Product> cart = [];

  @override
  void initState() {
    super.initState();
    shoppingList.add(Product(name: "New item"));
  }

  void _addItem() {
    setState(() {
      shoppingList.add(
        Product(name: "New item"),
      );
    });
  }

  void _deleteItem(Product item) {
    setState(() {
      if (cart.contains(item)) cart.remove(item);

      shoppingList.remove(item);
    });
  }

  void _toggleItemInCart(Product item) {
    setState(() {
      if (cart.contains(item)) {
        cart.remove(item);
      } else {
        cart.add(item);
      }
    });
  }

  void _removeAllItemsFromCart() {
    setState(() {
      cart = [];
    });
  }

  void _addAllItemsToCart() {
    setState(() {
      for (Product product in shoppingList) {
        if (!cart.contains(product)) cart.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _addAllItemsToCart(), 
              child: const Text("Check all items")
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _removeAllItemsFromCart(),
              child: const Text("Uncheck all items"),
            ),
          ]),
        Expanded(
          child: ListView.builder(
              itemCount: shoppingList.length,
              itemBuilder: (context, index) {
                return ShoppingListItem(
                  item: shoppingList[index],
                  inCart: cart.contains(shoppingList[index]),
                  toggleInCart: _toggleItemInCart,
                  deleteItem: _deleteItem,
                );
              }),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.red),
      home: 
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('ShoppingList'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: const ShoppingList(),
          ),
        ),
    );
  }
}
