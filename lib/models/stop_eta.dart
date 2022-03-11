class StopEta {
  final String eta;
  final int busId;
  final int secondsSpent;

  const StopEta(this.eta, this.busId, this.secondsSpent);

  StopEta.fromJson(Map<String, dynamic> json)
      : eta = json['eta'],
        busId = json['busId'].runtimeType == int
            ? json['busId']
            : int.parse(json['busId']),
        secondsSpent = json['secondsSpent'];
}
