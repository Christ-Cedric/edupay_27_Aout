/**
 * Normalise un numéro burkinabè vers le format canonique `+226XXXXXXXX`
 * (contrat §3.1 : "format +226… normalisé"). Accepte les saisies courantes
 * (avec/sans indicatif, préfixe `00`, espaces/tirets) — sans ça, "+226 76 69
 * 19 11" et "76691911" créeraient deux comptes distincts pour le même numéro,
 * et un login avec un format différent de celui saisi à la création échouerait.
 */
export function normalizePhone(phone: string): string {
  let digits = phone.replace(/[\s\-().]/g, '');

  if (digits.startsWith('00')) {
    digits = `+${digits.slice(2)}`;
  }

  if (!digits.startsWith('+')) {
    digits = digits.startsWith('226') ? `+${digits}` : `+226${digits}`;
  }

  return digits;
}
