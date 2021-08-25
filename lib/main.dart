import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slang_retail_assistant/slang_retail_assistant.dart';

void main() {
  runApp(new MaterialApp(home: new MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    implements RetailAssistantAction, RetailAssistantLifeCycleObserver {
  String _searchText = '';
  late SearchUserJourney _searchUserJourney;

  @override
  void initState() {
    super.initState();
    initSlangRetailAssistant();
  }

  void initSlangRetailAssistant() {
    var assistantConfig = new AssistantConfiguration()
      ..assistantId = "AssistantId"
      ..apiKey = "APIKey";

    SlangRetailAssistant.initialize(assistantConfig);
    SlangRetailAssistant.setAction(this);
    SlangRetailAssistant.setLifecycleObserver(this);
  }

  @override
  void onAssistantError(Map<String, String> assistantError) {
    print("AssistantError " + assistantError.toString());
  }

  @override
  SearchAppState onSearch(
      SearchInfo searchInfo, SearchUserJourney searchUserJourney) {
    _searchUserJourney = searchUserJourney;
    setState(() {
      try {
        JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        String searchMapString = encoder.convert(searchInfo);
        _searchText = searchMapString;
      } catch (e) {
        print(e);
      }
    });
    _showMyDialog();
    return SearchAppState.WAITING;
  }

  @override
  Widget build(BuildContext context) {
    SlangRetailAssistant.getUI().showTrigger();
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter example app'),
            ),
            body: Center(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(height: 16), // set height
                FlatButton(
                  minWidth: 50.0,
                  height: 50.0,
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: () {},
                ),
                Container(height: 16), // set height
                FlatButton(
                  minWidth: 50.0,
                  height: 50.0,
                  child: Text(
                    'Show Trigger',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    SlangRetailAssistant.getUI().showTrigger();
                  },
                ),
                Container(height: 16), // set height
                FlatButton(
                  minWidth: 50.0,
                  height: 50.0,
                  child: Text(
                    'Hide Trigger',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    SlangRetailAssistant.getUI().hideTrigger();
                  },
                ),
                Container(height: 16), // set height
                FlatButton(
                  minWidth: 50.0,
                  height: 50.0,
                  child: Text(
                    'Clear Search Context',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    SearchUserJourney.getContext().clear();
                  },
                ),
                Container(height: 16), // set height
                Flexible(
                    child: FractionallySizedBox(
                        widthFactor: 0.9,
                        heightFactor: 0.98,
                        child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.black,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '$_searchText\n',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ))))
              ],
            ))));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          title: Text('Search App State Condition'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select the search App state condition'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Search Success'),
              onPressed: () {
                _searchUserJourney.setSuccess();
                _searchUserJourney
                    .notifyAppState(SearchAppState.SEARCH_RESULTS);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search Failure'),
              onPressed: () {
                _searchUserJourney.setFailure();
                _searchUserJourney
                    .notifyAppState(SearchAppState.SEARCH_RESULTS);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search Item Not Found'),
              onPressed: () {
                _searchUserJourney.setItemNotFound();
                _searchUserJourney
                    .notifyAppState(SearchAppState.SEARCH_RESULTS);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search Item Not Specified'),
              onPressed: () {
                _searchUserJourney.setItemNotSpecified();
                _searchUserJourney
                    .notifyAppState(SearchAppState.SEARCH_RESULTS);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search Item Out of Stock'),
              onPressed: () {
                _searchUserJourney.setItemOutOfStock();
                _searchUserJourney
                    .notifyAppState(SearchAppState.SEARCH_RESULTS);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search Item need quantity'),
              onPressed: () {
                _searchUserJourney.setNeedItemQuantity();
                _searchUserJourney
                    .notifyAppState(SearchAppState.SEARCH_RESULTS);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void onAssistantClosed(bool isCancelled) {
    print("onAssistantClosed " + isCancelled.toString());
  }

  @override
  void onAssistantInitFailure(String description) {
    print("onAssistantInitFailure " + description);
  }

  @override
  void onAssistantInitSuccess() {
    print("onAssistantInitSuccess");
  }

  @override
  void onAssistantInvoked() {
    print("onAssistantInvoked");
  }

  @override
  void onAssistantLocaleChanged(Map<String, String> locale) {
    print("onAssistantLocaleChanged " + locale.toString());
  }

  @override
  void onOnboardingFailure() {
    print("onOnboardingFailure");
  }

  @override
  void onOnboardingSuccess() {
    print("onOnboardingSuccess");
  }

  @override
  void onUnrecognisedUtterance(String utterance) {
    print("onUnrecognisedUtterance " + utterance);
  }

  @override
  void onUtteranceDetected(String utterance) {
    print("onUtteranceDetected " + utterance);
  }

  @override
  void onMicPermissionDenied() {
    print("onMicPermissionDenied");
  }
}

class UserCanceled {}

class QRViewExample {}
