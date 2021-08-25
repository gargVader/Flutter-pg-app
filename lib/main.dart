import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String ASSISTANT_ID = "";
  String API_KEY = "";
  String scanRes = "";

  @override
  void initState() {
    super.initState();
    initSlangRetailAssistant();
  }

  void initSlangRetailAssistant() async {
    final prefs = await SharedPreferences.getInstance();
    ASSISTANT_ID = prefs.getString('ASSISTANT_ID') ?? "x";
    API_KEY = prefs.getString('API_KEY') ?? "x";

    var assistantConfig = new AssistantConfiguration()
      ..assistantId = ASSISTANT_ID
      ..apiKey = API_KEY;

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

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();

    print(barcodeScanRes);
    setState(() {
      scanRes = barcodeScanRes;
      List<String> list = scanRes.split(':').toList();
      prefs.setString('ASSISTANT_ID', list[1]);
      prefs.setString('API_KEY', list[2]);
      initSlangRetailAssistant();
    });
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
                  onPressed: () => scanQR(),
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
