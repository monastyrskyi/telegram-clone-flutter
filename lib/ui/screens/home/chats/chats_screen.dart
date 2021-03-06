import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telegram_clone_mobile/ui/shared_widgets/appbar_icon_button.dart';
import 'package:telegram_clone_mobile/ui/theming/theme_switcher_area.dart';
import 'package:telegram_clone_mobile/view_models/home/chats/chats_viewmodel.dart';
import 'package:telegram_clone_mobile/view_models/home/chats/dialog_list_item_viewmodel.dart';
import 'package:telegram_clone_mobile/view_models/home/chats/dialog_viewmodel.dart';
import 'package:telegram_clone_mobile/view_models/home/chats/nav_drawer_viewmodel.dart';
import 'package:telegram_clone_mobile/view_models/home/chats/saved_messages_list_item_viewmodel.dart';
import 'package:telegram_clone_mobile/view_models/home/chats/saved_messages_viewmodel.dart';

import 'strings.dart';
import 'widgets/chat_loading_list_item.dart';
import 'widgets/dialog_list_item.dart';
import 'widgets/nav_drawer.dart';
import 'widgets/saved_messages_list_item.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read<ChatsViewModel>().loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcherArea(
      child: Scaffold(
        drawer: ChangeNotifierProvider<NavDrawerViewModel>(
          create: (_) => NavDrawerViewModel(),
          child: NavDrawer(),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return AppBarIconButton(
                icon: Icons.menu,
                onTap: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          title: const Text(ChatsStrings.kTitle),
          actions: <Widget>[
            AppBarIconButton(
              onTap: () {},
              icon: Icons.search,
              iconSize: 24.0,
              iconColor: Theme.of(context).textTheme.headline1!.color!,
            ),
          ],
        ),
        body: Selector<ChatsViewModel, bool>(
          selector: (context, model) => model.chatsLoaded,
          builder: (context, chatsLoaded, child) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              reverseDuration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              child: chatsLoaded ? _buildChatList() : _buildChatListLoader(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatsViewModel>(
      builder: (context, model, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final chatViewModel = model.chats[index];

            if (chatViewModel is SavedMessagesViewModel) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider<SavedMessagesViewModel>.value(
                    value: chatViewModel,
                  ),
                  ChangeNotifierProxyProvider<SavedMessagesViewModel,
                      SavedMessagesListItemViewModel>(
                    create: (_) => SavedMessagesListItemViewModel(),
                    update: (_, viewModel, listItemViewModel) =>
                        listItemViewModel!..update(viewModel),
                  ),
                ],
                child: SavedMessagesListItem(),
              );
            } else if (chatViewModel is DialogViewModel) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider<DialogViewModel>.value(
                    value: chatViewModel,
                  ),
                  ChangeNotifierProxyProvider<DialogViewModel,
                      DialogListItemViewModel>(
                    create: (_) => DialogListItemViewModel(),
                    update: (_, viewModel, listItemViewModel) =>
                        listItemViewModel!..update(viewModel),
                  ),
                ],
                child: DialogListItem(),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          itemCount: model.chats.length,
        );
      },
    );
  }

  Widget _buildChatListLoader() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (int i = 0; i < 12; i++) ChatLoadingListItem(),
      ],
    );
  }
}
