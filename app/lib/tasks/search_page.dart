import 'package:flutter/material.dart';

import 'package:flutter_search_bar/flutter_search_bar.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: Text('Search'),
        actions: [searchBar.getSearchAction(context)]);
  }

  _SearchPageState() {
    searchBar = SearchBar(
      inBar: false,
      closeOnSubmit: false,
      hintText: 'Enter your task!',
      setState: setState,
      onSubmitted: (String submission) {
        print(submission);
      },
      buildDefaultAppBar: buildAppBar,
    );

    // Start with searching true.
    searchBar.isSearching.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchBar.build(context), body: Center(child: Text('hello')));
  }
}
