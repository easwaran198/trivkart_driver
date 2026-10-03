class EarningsSummary {
  final int rides;
  final double amount;

  EarningsSummary({
    required this.rides,
    required this.amount,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      rides: json['rides'] is int
          ? json['rides']
          : int.tryParse(json['rides']?.toString() ?? '0') ?? 0,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class EarningsModel {
  final EarningsSummary today;
  final EarningsSummary month;
  final EarningsSummary total;

  EarningsModel({
    required this.today,
    required this.month,
    required this.total,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      today: json['today'] != null
          ? EarningsSummary.fromJson(json['today'])
          : EarningsSummary(rides: 0, amount: 0.0),
      month: json['month'] != null
          ? EarningsSummary.fromJson(json['month'])
          : EarningsSummary(rides: 0, amount: 0.0),
      total: json['total'] != null
          ? EarningsSummary.fromJson(json['total'])
          : EarningsSummary(rides: 0, amount: 0.0),
    );
  }
}
