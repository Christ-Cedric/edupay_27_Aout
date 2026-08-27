import '../../../core/network/api_client.dart';
import '../../../core/network/api_routes.dart';
import '../domain/models/season.dart';
import 'season_data_source.dart';

Season _parseSeason(Map<String, dynamic> json) {
  return Season(
    id: json['id'] as String,
    label: json['label'] as String,
    launchDate: DateTime.parse(json['launch_date'] as String),
    deliveryDeadline: DateTime.parse(json['delivery_deadline'] as String),
    enrollmentOpen: json['enrollment_open'] as bool,
    refundFee: json['refund_fee'] as int,
    isCurrent: json['is_current'] as bool,
  );
}

/// Implémentation backend du seam [SeasonDataSource] (endpoints
/// `/admin/seasons`, contrat partagé §5.4).
class RestSeasonDataSource implements SeasonDataSource {
  const RestSeasonDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Season> fetchCurrent() async {
    final seasons = await _fetchAllRaw();
    final current = seasons.firstWhere(
      (s) => s['is_current'] == true,
      orElse: () => seasons.isNotEmpty ? seasons.first : const {},
    );
    return _parseSeason(current);
  }

  @override
  Future<List<Season>> fetchAll() async {
    final seasons = await _fetchAllRaw();
    return seasons.map(_parseSeason).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchAllRaw() async {
    final json = await _client.get(ApiRoutes.adminSeasons);
    return (json['data'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
  }

  @override
  Future<Season> update(Season season) async {
    final json = await _client.patch(
      ApiRoutes.adminSeasonDetail(season.id),
      body: {
        'label': season.label,
        'launch_date': season.launchDate.toIso8601String(),
        'delivery_deadline': season.deliveryDeadline.toIso8601String(),
        'enrollment_open': season.enrollmentOpen,
        'refund_fee': season.refundFee,
      },
    );
    return _parseSeason(json);
  }

  @override
  Future<Season> create(Season season) async {
    final json = await _client.post(
      ApiRoutes.adminSeasons,
      body: {
        'label': season.label,
        'launch_date': season.launchDate.toIso8601String(),
        'delivery_deadline': season.deliveryDeadline.toIso8601String(),
        'enrollment_open': season.enrollmentOpen,
        'refund_fee': season.refundFee,
      },
    );
    return _parseSeason(json);
  }

  @override
  Future<Season> setCurrent(String id) async {
    final json = await _client.post(ApiRoutes.adminSetCurrentSeason(id));
    return _parseSeason(json);
  }
}
