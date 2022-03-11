class StopEta {
  final String eta;
  final String busName;
  final int secondsSpent;
  final String routeName;

  const StopEta(this.eta, this.busName, this.secondsSpent, this.routeName);

  StopEta.fromJson(Map<String, dynamic> json)
      : eta = json['eta'],
        busName = json['busName'],
        secondsSpent = json['secondsSpent'],
        routeName = json['theStop']['routeName'];
}
