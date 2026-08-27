import '../domain/models/season.dart';
import 'season_data_source.dart';

/// Source de données en mémoire, seedée avec la saison affichée par le
/// prototype (écran `ad_pa`) et une saison passée (pour vérifier l'écran de
/// liste avec plus d'une saison). Mode `mock` du seam [SeasonDataSource].
class FakeSeasonDataSource implements SeasonDataSource {
  final List<Season> _seasons = [
    Season(
      id: 'season-current',
      label: '2025-2026',
      launchDate: DateTime(2026, 6, 24),
      deliveryDeadline: DateTime(2026, 10),
      enrollmentOpen: true,
      refundFee: 500,
      isCurrent: true,
    ),
    Season(
      id: 'season-past',
      label: '2024-2025',
      launchDate: DateTime(2025, 6, 20),
      deliveryDeadline: DateTime(2025, 10),
      enrollmentOpen: false,
      refundFee: 500,
      isCurrent: false,
    ),
  ];

  @override
  Future<Season> fetchCurrent() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _seasons.firstWhere((s) => s.isCurrent, orElse: () => _seasons.first);
  }

  @override
  Future<List<Season>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_seasons);
  }

  @override
  Future<Season> update(Season season) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _seasons.indexWhere((s) => s.id == season.id);
    _seasons[index] = season;
    return season;
  }

  @override
  Future<Season> create(Season season) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final created = season.copyWith(
      id: 'season-${_seasons.length + 1}',
      isCurrent: false,
    );
    _seasons.add(created);
    return created;
  }

  @override
  Future<Season> setCurrent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var i = 0; i < _seasons.length; i++) {
      _seasons[i] = _seasons[i].copyWith(isCurrent: _seasons[i].id == id);
    }
    return _seasons.firstWhere((s) => s.id == id);
  }
}
