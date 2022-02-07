import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_test/api/dto/account_response.dart';
import 'package:web_test/models/app_model.dart';
import 'package:web_test/utils/ui.dart';
import 'package:web_test/screens/account_details.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with Dialogs {
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    var appModel = Provider.of<AppModel>(context, listen: false);
    appModel.showDialog = showSimpleDialog;

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          var appModel = Provider.of<AppModel>(context, listen: false);
          appModel.loadNextPage();
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
        AppBar(title: const Text('Test Dynamics 365'), actions: <Widget>[
          Consumer<AppModel>(builder: (context, app, child) {
            if (app.accessToken != null) {
              return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: app.logout);
            } else {
              return IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: 'Login',
                  onPressed: app.login);
            }
          }),
        ]),
        body: Consumer<AppModel>(
          builder: (context, app, child) {
            return Column(
              children: <Widget>[
                _buildSearchBar(app),
                Expanded(child: _buildList(app)),
              ],
            );
          },
        ));
  }

  Widget _buildSearchBar(AppModel app) {
    if (app.accessToken != null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child:
            DropdownButton(
                hint: Row(
                  children: const [
                    Icon(Icons.filter_alt),
                    Text("Filter"),
                  ],
                ),
                icon: const Icon(Icons.filter, color: Colors.transparent,
                ),
                items: [
                  DropdownMenuItem(
                      enabled: false,
                      value: "",
                      child: Column(
                        children: [
                          const Text(
                            "Filter by account status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ToggleButtons(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              isSelected: [
                                app.accountState == AccountState.active,
                                app.accountState == AccountState.inactive,
                                app.accountState == null,
                              ],
                              children: [
                                Text(
                                  "Active",
                                  style: TextStyle(
                                      color: _toggleColor(
                                          context,
                                          app.accountState ==
                                              AccountState.active)),
                                ),
                                Text(
                                  "Inactive",
                                  style: TextStyle(
                                      color: _toggleColor(
                                          context,
                                          app.accountState ==
                                              AccountState.inactive)),
                                ),
                                Text(
                                  "Any",
                                  style: TextStyle(
                                      color: _toggleColor(
                                          context, app.accountState == null)),
                                ),
                              ],
                              onPressed: (i) {
                                app.accountState = AccountState.values.length == i
                                    ? null
                                    : AccountState.values[i];
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      )),
                  const DropdownMenuItem(
                    enabled: false,
                    value: "",
                    child: Text(
                      "Filter by State/Province",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownMenuItem(
                    child: Text(
                      "Any State/Province",
                      style: TextStyle(
                        color: _toggleColor(
                            context, app.selectedStateOrProvince == null),
                      ),
                    ),
                    value: "",
                  ),
                  for (var state in app.statesList)
                    DropdownMenuItem(
                      child: Text(
                        state,
                        style: TextStyle(
                          color: _toggleColor(
                              context, app.selectedStateOrProvince == state),
                        ),
                      ),
                      value: state,
                    ),
                ],
                onChanged: (value) => app.selectedStateOrProvince = value
            ),
          ),
          IconButton(
            onPressed: () => app.isListRepresentation = true,
            icon: Icon(
              Icons.view_list,
              color: _toggleColor(context, app.isListRepresentation),
            ),
          ),
          IconButton(
            onPressed: () => app.isListRepresentation = false,
            icon: Icon(
              Icons.grid_view,
              color: _toggleColor(context, !app.isListRepresentation),
            ),
          ),
        ],
      );
    } else {
      return const Text("Please log in to see the list of accounts");
    }
  }

  Widget _buildProgressIndicator(AppModel appModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: appModel.isLoading ? 1.0 : 00,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildList(AppModel appModel) {
    if (appModel.isListRepresentation) {
      return ListView.builder(
        itemCount: appModel.accountsList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          return _listItemBuilder(appModel, context, index);
        },
        controller: _scrollController,
      );
    } else {
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2,
        children: [
          for (var e in appModel.accountsList)
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountDetails(e)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                  Column(
                    children: [
                      Expanded(child: Container(color: Colors.grey,)),
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: Text(e.name),
                        subtitle: Text("Account number: ${ e.accountNumber ?? "N/A" }"),
                      ),
                    ],
                  )
                ),
              ),
            ),
          _buildProgressIndicator(appModel),
        ],
        controller: _scrollController,
      );
    }
  }

  Widget _listItemBuilder(AppModel appModel, BuildContext context, int index) {
    if (index == appModel.accountsList.length) {
      return _buildProgressIndicator(appModel);
    } else {
      return Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountDetails(appModel.accountsList[index])),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.image),
              title: Text(appModel.accountsList[index].name),
              subtitle: Text("Account number: ${ appModel.accountsList[index].accountNumber ?? "N/A" }"),
            ),
          ),
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      var app = Provider.of<AppModel>(context, listen: false);
      app.searchText = query;
    });
  }



  Color? _toggleColor(BuildContext context, bool isSelected) {
    return isSelected ? Theme.of(context).colorScheme.secondary : null;
  }
}