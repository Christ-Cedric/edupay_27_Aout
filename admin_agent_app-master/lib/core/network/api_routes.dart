/// Chemins d'API (relatifs à la base versionnée `/api/v1`), dérivés du
/// catalogue d'endpoints du contrat partagé (`docs/SHARED_API_CONTRACT.md`,
/// §5). Périmètre Admin/Agent uniquement — les routes parent appartiennent à
/// l'app Client.
///
/// ⚠️ Ces chemins restent PROVISOIRES tant que le contrat n'est pas gelé
/// (7 points ouverts, §7). Ne pas coder de mapping DTO définitif dessus avant
/// validation inter-équipes.
abstract final class ApiRoutes {
  ApiRoutes._();

  // Auth (commun) — §2
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';

  // Admin — §5.4
  static const adminDashboard = '/admin/dashboard';
  static const adminFamilies = '/admin/families';
  static const adminFamiliesPending = '/admin/families/pending';
  static String adminFamily(String id) => '/admin/families/$id';
  static String adminApproveFamily(String id) => '/admin/families/$id/approve';
  static String adminRejectFamily(String id) => '/admin/families/$id/reject';
  static String adminFamilyIncident(String id) => '/admin/families/$id/incident';
  static const adminNotifications = '/admin/notifications';
  // Marquage lu commun aux 3 rôles, monté à la racine `/notifications`.
  static String notificationRead(String id) => '/notifications/$id/read';
  static const adminAgents = '/admin/agents';
  static String adminAgent(String id) => '/admin/agents/$id';
  static String adminSuspendAgent(String id) => '/admin/agents/$id/suspend';
  static String adminReactivateAgent(String id) => '/admin/agents/$id/reactivate';
  static const adminKits = '/admin/kits';
  static String adminKit(String id) => '/admin/kits/$id';
  static const adminKitsImport = '/admin/kits/import';
  static const adminSupplies = '/admin/supplies';
  static String adminSupply(String id) => '/admin/supplies/$id';
  static const adminVehicles = '/admin/vehicles';
  static String adminVehicle(String id) => '/admin/vehicles/$id';
  static const adminRefunds = '/admin/refunds';
  static String adminRefund(String id) => '/admin/refunds/$id';
  static String adminApproveRefund(String id) => '/admin/refunds/$id/approve';
  static String adminRejectRefund(String id) => '/admin/refunds/$id/reject';
  static const adminSeasons = '/admin/seasons';
  static String adminSeasonDetail(String id) => '/admin/seasons/$id';
  static String adminSetCurrentSeason(String id) =>
      '/admin/seasons/$id/set-current';
  static const adminAuditLogs = '/admin/audit-logs';
  static const adminContributions = '/admin/contributions';
  static String adminFamilyContributions(String id) =>
      '/admin/families/$id/contributions';
  static String adminFamilyChildren(String id) => '/admin/families/$id/children';
  static String adminFamilyChild(String id, String childId) =>
      '/admin/families/$id/children/$childId';
  static String adminAssignChildKit(String id, String childId) =>
      '/admin/families/$id/children/$childId/kit';
}
