class Data {
  bool showLoading = true;
  static final Data _instance = Data._privateConstructor();

  Data._privateConstructor();

  static Data get instance => _instance;
}
