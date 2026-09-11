enum PlanFrequency { daily, weekly, monthly }
enum ContributionStatus { upcoming, due, paid, failed }

class MockContribution {
  final String id;
  final double amount;
  final DateTime dueDate;
  ContributionStatus status;

  MockContribution({
    required this.id,
    required this.amount,
    required this.dueDate,
    this.status = ContributionStatus.upcoming,
  });
}

class MockTransportPlan {
  static List<MockTransportPlan> activePlans = [];

  final String id;
  final String transportName;
  final double transportPrice;
  
  PlanFrequency? frequency;
  double capacity;
  
  List<MockContribution> contributions = [];

  MockTransportPlan({
    required this.id,
    required this.transportName,
    required this.transportPrice,
    this.frequency,
    this.capacity = 0,
  });

  bool get isActive => contributions.isNotEmpty;

  double get totalPaid {
    return contributions
        .where((c) => c.status == ContributionStatus.paid)
        .fold(0, (sum, c) => sum + c.amount);
  }

  double get remainingAmount => transportPrice - totalPaid;
  double get progress => transportPrice > 0 ? (totalPaid / transportPrice) : 0;

  void generateContributions() {
    contributions.clear();
    if (frequency == null || capacity <= 0) return;

    int fullContributions = (transportPrice / capacity).floor();
    double remainder = transportPrice - (fullContributions * capacity);
    
    DateTime nextDate = DateTime.now();

    for (int i = 0; i < fullContributions; i++) {
      contributions.add(MockContribution(
        id: 'cot_${i + 1}',
        amount: capacity,
        dueDate: nextDate,
        status: i == 0 ? ContributionStatus.due : ContributionStatus.upcoming,
      ));
      nextDate = _getNextDate(nextDate, frequency!);
    }

    if (remainder > 0) {
      contributions.add(MockContribution(
        id: 'cot_final',
        amount: remainder,
        dueDate: nextDate,
        status: fullContributions == 0 ? ContributionStatus.due : ContributionStatus.upcoming,
      ));
    }
  }

  DateTime _getNextDate(DateTime current, PlanFrequency freq) {
    switch (freq) {
      case PlanFrequency.daily:
        return current.add(const Duration(days: 1));
      case PlanFrequency.weekly:
        return current.add(const Duration(days: 7));
      case PlanFrequency.monthly:
        return DateTime(current.year, current.month + 1, current.day);
    }
  }
}
