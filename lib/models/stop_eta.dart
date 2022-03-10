class StopEta {
  final String eta;

  const StopEta(this.eta);

  StopEta.fromJson(Map<String, dynamic> json) : eta = json['eta'];
}
