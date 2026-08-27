/// Rôle porté par une session authentifiée.
///
/// `agent` existe déjà dans le modèle même si le module Agent terrain n'est
/// pas construit dans ce périmètre — un coéquipier l'ajoutera plus tard sans
/// toucher à ce fichier.
enum UserRole { admin, agent }
