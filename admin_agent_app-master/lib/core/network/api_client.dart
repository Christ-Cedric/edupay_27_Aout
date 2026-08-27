/// Contrat de transport HTTP, indépendant du package client concret.
///
/// Les `RestDataSource` de chaque feature dépendent de cette interface (jamais
/// de Dio directement), ce qui permet de les tester avec un faux [ApiClient]
/// et de changer de transport sans toucher au code métier.
///
/// Convention de retour : toujours un `Map<String, dynamic>`. Les réponses de
/// type liste sont enveloppées par le backend dans `{ "data": [...] }`
/// (contrat §1), donc renvoyées telles quelles ici.
abstract interface class ApiClient {
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query});

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body});

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body});

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body});

  Future<void> delete(String path, {Map<String, dynamic>? body});
}
