import 'package:edupay/features/parent/domain/parent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parent profile serializes to the REST payload', () {
    const profile = ParentProfile(
      fullName: 'Aminata Kabore',
      phone: '+226 70 00 00 00',
      city: 'Koudougou',
      district: 'Secteur 3',
    );

    expect(ParentProfile.fromJson(profile.toJson()).fullName, profile.fullName);
  });

  test('child profile supports snake_case REST payloads', () {
    final child = ChildProfile.fromJson({
      'first_name': 'Awa',
      'level': 'CM2',
      'school': 'Centre',
      'kit_selection': {'type': 'standard', 'kit_id': 'basic'},
      'saved_amount': 500,
    });

    expect(child.kitSelection?.standardKit, SchoolKit.basic);
    expect(child.savedAmount, 500);
  });

  test('builds the operator-specific USSD payment codes', () {
    expect(
      ussdCodeFor(PaymentMethod.orangeMoney, 2500),
      '*144*10*541515907*2500#',
    );
    expect(
      ussdCodeFor(PaymentMethod.moovMoney, 2500),
      '*555*1*2*72006904*2500#',
    );
  });

  test('restores contribution allocations from the server response', () {
    final contribution = Contribution.fromJson({
      'created_at': '2026-08-19T10:00:00Z',
      'method': 'cashAgent',
      'reference': 'COT-2026-TEST',
      'amount': 2500,
      'status': 'confirmed',
      'allocations': [
        {'child_first_name': 'Awa', 'amount': 2500},
      ],
    });

    expect(contribution.success, isTrue);
    expect(contribution.allocations.single.childFirstName, 'Awa');
    expect(contribution.allocations.single.amount, 2500);
  });
}
