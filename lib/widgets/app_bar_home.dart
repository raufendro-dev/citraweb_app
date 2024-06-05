import 'package:flutter/material.dart';

import 'app_bar_shoping_cart.dart';
import 'custom_search_delegate.dart';

enum Leading {
  kosong,
  back,
  close,
}

class AppBarHome extends StatelessWidget with PreferredSizeWidget {
  const AppBarHome({
    Key? key,
    this.leading = Leading.kosong,
    this.hint = 'Cari di Citraweb',
  }) : super(key: key);

  final Leading leading;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: leading == Leading.kosong
          ? null
          : leading == Leading.back
              ? const BackButton()
              : leading == Leading.close
                  ? const CloseButton()
                  : null,
      titleSpacing: leading == Leading.kosong ? 16 : 0,
      title: SizedBox(
        width: double.infinity,
        height: 40,
        child: TextField(
          readOnly: true,
          onTap: () async {
            await showSearch(
                context: context, delegate: CustomSearchDelegate());
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
            ),
            prefixIconConstraints:
                BoxConstraints.tight(const Size.fromWidth(36)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            hintMaxLines: 1,
            filled: true,
            fillColor: Theme.of(context).colorScheme.background,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(22.0)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.background,
                width: 4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(22.0)),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.background)),
            enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(22.0)),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.background)),
            hintText: hint,
            isDense: false,
            hintStyle: const TextStyle(height: 1.5),
          ),
        ),
      ),
      actions: [
        // IconButton(
        //   onPressed: () => {},
        //   icon: const Icon(Icons.mail_outline),
        //   splashRadius: 24,
        //   color: Theme.of(context).colorScheme.background,
        // ),
        Padding(
          padding: leading == Leading.kosong
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 16),
          child: AppBarShopingCart(),
        ),
        IconButton(
          onPressed: () => {Scaffold.of(context).openEndDrawer()},
          icon: const Icon(Icons.menu),
          splashRadius: 24,
          color: Theme.of(context).colorScheme.background,
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
