import 'mock_transport_plan.dart'; // For PlanFrequency and ContributionStatus

class MockSchoolingContribution {
  final String id;
  final double amount;
  final DateTime dueDate;
  ContributionStatus status;

  MockSchoolingContribution({
    required this.id,
    required this.amount,
    required this.dueDate,
    this.status = ContributionStatus.upcoming,
  });
}

class MockSchoolingPlan {
  static List<MockSchoolingPlan> activePlans = [];

  final String id; // usually childId
  final String childName;
  final double targetAmount;
  
  PlanFrequency? frequency;
  double capacity;
  
  List<MockSchoolingContribution> contributions = [];
  double savedAmount = 0; // Pour simuler l'historique de paiements

  MockSchoolingPlan({
    required this.id,
    required this.childName,
    required this.targetAmount,
    this.frequency,
    this.capacity = 0,
    this.savedAmount = 0,
  });

  bool get isActive => contributions.isNotEmpty;

  double get totalPaid {
    double paidFromContributions = contributions
        .where((c) => c.status == ContributionStatus.paid)
        .fold(0, (sum, c) => sum + c.amount);
    return savedAmount + paidFromContributions;
  }

  double get remainingAmount => targetAmount - totalPaid;
  double get progress => targetAmount > 0 ? (totalPaid / targetAmount).clamp(0.0, 1.0) : 0;

  DateTime get deadline {
    final now = DateTime.now();
    // Si on est entre Juin et Décembre, la limite pour payer la scolarité de l'année qui commence est le 15 Septembre de l'année suivante.
    // Si on est entre Janvier et Mai, la limite est le 15 Septembre de l'année en cours.
    if (now.month >= 6) {
       return DateTime(now.year + 1, 9, 15);
    }
    return DateTime(now.year, 9, 15);
  }

  bool get isCapacityDivisible {
    if (capacity <= 0) return false;
    return true;
  }

  bool get isValidDeadline {
    if (capacity <= 0 || frequency == null) return false;
    if (remainingAmount <= 0) return true;

    int fullContributions = (remainingAmount / capacity).floor();
    double remainder = remainingAmount - (fullContributions * capacity);
    int totalContributions = fullContributions + (remainder > 0 ? 1 : 0);

    DateTime nextDate = DateTime.now();
    for (int i = 0; i < totalContributions; i++) {
       if (i > 0) nextDate = _getNextDate(nextDate, frequency!);
    }
    return nextDate.isBefore(deadline) || nextDate.isAtSameMomentAs(deadline);
  }
  
  DateTime get estimatedEndDate {
    if (capacity <= 0 || frequency == null || remainingAmount <= 0) return DateTime.now();

    int fullContributions = (remainingAmount / capacity).floor();
    double remainder = remainingAmount - (fullContributions * capacity);
    int totalContributions = fullContributions + (remainder > 0 ? 1 : 0);

    DateTime nextDate = DateTime.now();
    for (int i = 0; i < totalContributions; i++) {
       if (i > 0) nextDate = _getNextDate(nextDate, frequency!);
    }
    return nextDate;
  }
  
  int get estimatedContributionCount {
    if (capacity <= 0 || remainingAmount <= 0) return 0;
    int fullContributions = (remainingAmount / capacity).floor();
    double remainder = remainingAmount - (fullContributions * capacity);
    return fullContributions + (remainder > 0 ? 1 : 0);
  }

  void generateContributions() {
    contributions.clear();
    if (frequency == null || capacity <= 0) return;
    if (remainingAmount <= 0) return;

    int fullContributions = (remainingAmount / capacity).floor();
    double remainder = remainingAmount - (fullContributions * capacity);
    
    DateTime nextDate = DateTime.now();

    for (int i = 0; i < fullContributions; i++) {
      contributions.add(MockSchoolingContribution(
        id: 'cot_${i + 1}',
        amount: capacity,
        dueDate: nextDate,
        status: i == 0 ? ContributionStatus.due : ContributionStatus.upcoming,
      ));
      nextDate = _getNextDate(nextDate, frequency!);
    }

    if (remainder > 0) {
      contributions.add(MockSchoolingContribution(
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
