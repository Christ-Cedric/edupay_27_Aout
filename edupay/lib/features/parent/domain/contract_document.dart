import 'parent_models.dart';
import 'savings_engine.dart';
import 'school_catalogue.dart';

/// Modèle de contenu du contrat EduP@y — reproduit fidèlement le contrat
/// Word fourni (`EduPay_Contrat_Parent_CGV.docx`, à la racine du dépôt),
/// réorganisé en sections pour un affichage mobile (à l'image d'une page
/// Politique de confidentialité) plutôt qu'en tableaux façon document papier.
/// Les tableaux du modèle (plans de cotisation, résiliation) sont donc rendus
/// en listes à puces, plus lisibles sur petit écran, mais leur contenu texte
/// est repris mot pour mot.
///
/// Personnalisé avec les données réelles du client (nom, téléphone, ville,
/// enfants, kits, montant total, fréquence) — jamais de valeur inventée : ce
/// qui n'est pas encore modélisé côté app (pièce d'identité, profession...)
/// est simplement omis plutôt que rempli de données fictives.
class ContractSection {
  const ContractSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}

class ContractDocument {
  const ContractDocument({
    required this.contractNumber,
    required this.date,
    required this.sections,
  });

  final String contractNumber;
  final DateTime date;
  final List<ContractSection> sections;
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padStart2}/${d.month.toString().padStart2}/${d.year}';

extension on String {
  String get padStart2 => length >= 2 ? this : '0$this';
}

String _money(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
  }
  return buffer.toString();
}

/// Construit le contrat personnalisé pour l'état courant de la souscription.
ContractDocument buildContractDocument({
  required ParentProfile? profile,
  required List<ChildProfile> children,
  required SavingsPlan plan,
  required int totalGoal,
  required int installmentAmount,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final clientName = profile?.fullName.trim();
  // Numéro de contrat stable pour ce client (basé sur son code famille s'il
  // existe déjà) plutôt qu'un compteur global non disponible côté app.
  final suffix = (profile?.familyCode?.isNotEmpty ?? false)
      ? profile!.familyCode!
      : today.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
  final contractNumber = 'EP-CONT-${today.year}-$suffix';

  final childrenLines = children.isEmpty
      ? ['Aucun enfant enregistré pour le moment.']
      : children.map((c) {
          final details = <String>[];
          if (c.kitSelection != null) {
            details.add(
              '${c.kitSelection!.title} (${_money(c.resolvedKit?.price ?? 0)} F)',
            );
          }
          if (c.tuitionAmount > 0) {
            details.add('Scolarité : ${_money(c.tuitionAmount)} F');
          }
          if (c.transportAmount > 0) {
            details.add(
              '${c.transportType ?? "Transport"} : ${_money(c.transportAmount)} F',
            );
          }
          final summary = details.isEmpty
              ? 'aucun objectif sélectionné'
              : '${details.join(" + ")} (Total : ${_money(c.totalCost)} FCFA)';
          return '${c.firstName} — ${c.school}, classe ${c.level} — $summary';
        }).toList();

  final planPeriods = SavingsPlan.values
      .map(
        (p) =>
            '${p == plan ? '✓ ' : '☐ '}${p.title} — '
            '${_money(p.amount)} FCFA minimum / ${p.period}',
      )
      .toList();

  final after1 = installmentAmount.clamp(0, totalGoal);
  final after2 = (installmentAmount * 2).clamp(0, totalGoal);
  final after3 = (installmentAmount * 3).clamp(0, totalGoal);

  return ContractDocument(
    contractNumber: contractNumber,
    date: today,
    sections: [
      ContractSection(
        title: 'Identification des parties',
        paragraphs: [
          'LE PRESTATAIRE — EduP@y\n'
              'Raison sociale : EduP@y\n'
              'Adresse : Ouagadougou, Burkina Faso\n'
              'EduP@y n\'est pas un établissement financier ou bancaire ; il s\'agit '
              'd\'un service de collecte d\'épargne volontaire et de commande '
              'groupée de fournitures scolaires.',
          'LE CLIENT — PARENT / TUTEUR\n'
              'Nom & Prénom : ${clientName?.isNotEmpty ?? false ? clientName : 'Non renseigné'}\n'
              'Téléphone : ${profile?.phone.isNotEmpty ?? false ? profile!.phone : 'Non renseigné'}\n'
              'Ville / Secteur : ${profile?.city.isNotEmpty ?? false ? profile!.city : 'Non renseigné'}'
              '${profile?.district.isNotEmpty ?? false ? ', ${profile!.district}' : ''}',
        ],
      ),
      ContractSection(
        title: '🎒 Enfant(s) bénéficiaire(s)',
        paragraphs: ['Année scolaire : $kSchoolYear', ...childrenLines],
      ),
      const ContractSection(
        title: 'Article 1 — Objet du Contrat',
        paragraphs: [
          'Le présent contrat a pour objet de définir les conditions dans '
              'lesquelles EduP@y fournit au Client un service d\'épargne '
              'progressive destiné à financer l\'achat de fournitures scolaires '
              'pour le(s) enfant(s) désigné(s) ci-dessus, avec livraison à '
              'domicile avant la rentrée scolaire.',
          'EduP@y n\'est pas un établissement financier ou bancaire. Il s\'agit '
              'd\'un service de collecte d\'épargne volontaire et de commande '
              'groupée de fournitures scolaires.',
        ],
      ),
      const ContractSection(
        title: 'Article 2 — Fonctionnement du Service',
        paragraphs: [
          'Le service EduP@y fonctionne en trois phases :',
          'Phase 1 — Épargne : le Client cotise librement selon le plan '
              'choisi (journalier, hebdomadaire ou mensuel). Chaque cotisation '
              'est enregistrée et un reçu officiel est émis.',
          'Phase 2 — Commande : lorsque l\'épargne du Client atteint le '
              'montant objectif défini à l\'Article 4, EduP@y procède à la '
              'commande des fournitures auprès des fournisseurs partenaires.',
          'Phase 3 — Livraison : les fournitures sont livrées à l\'adresse du '
              'Client avant la date de rentrée convenue, contre signature d\'un '
              'bon de livraison.',
        ],
      ),
      ContractSection(
        title: 'Article 3 — Plan de Cotisation',
        paragraphs: [
          'Le Client choisit l\'un des plans de cotisation suivants au moment '
              'de l\'inscription (moyens de paiement acceptés : Orange Money, '
              'Moov Money, Espèces, et Virement pour le plan mensuel) :',
          ...planPeriods,
          'Le Client peut modifier son plan de cotisation en informant '
              'EduP@y par écrit (WhatsApp ou SMS) avec un préavis de 7 jours.',
        ],
      ),
      ContractSection(
        title: 'Article 4 — Montant Objectif & Panier de Fournitures',
        paragraphs: [
          'Montant objectif total : ${_money(totalGoal)} FCFA',
          'Date de début de cotisation : ${_formatDate(today)}',
          'Date limite (objectif atteint au plus tard) : '
              '${_formatDate(kSubscriptionDeadline)}',
          'La liste des fournitures à acheter sera établie conjointement par '
              'le Client et EduP@y avant le début de la phase de commande. '
              'EduP@y s\'engage à acheter exactement les articles figurant sur '
              'cette liste, dans la limite du budget disponible.',
          'En cas d\'insuffisance du budget collecté à la date de livraison, '
              'EduP@y informera le Client et proposera soit un report de '
              'livraison, soit une livraison partielle avec accord du Client.',
        ],
      ),
      const ContractSection(
        title: 'Article 5 — Obligations d\'EduP@y',
        paragraphs: [
          '• Émettre un reçu officiel pour chaque cotisation reçue, dans les 24 heures',
          '• Envoyer un relevé mensuel de l\'épargne au Client par WhatsApp',
          '• Conserver l\'épargne collectée exclusivement pour l\'achat des fournitures du Client',
          '• Acheter les fournitures auprès de fournisseurs de confiance et garantir leur qualité',
          '• Livrer les fournitures à l\'adresse du Client avant la date convenue',
          '• Informer le Client dans les 48 heures de tout problème pouvant affecter la livraison',
          '• Garder confidentielles les informations personnelles du Client',
        ],
      ),
      const ContractSection(
        title: 'Article 6 — Obligations du Client',
        paragraphs: [
          '• Cotiser régulièrement selon le plan choisi et les engagements pris',
          '• Informer EduP@y de tout changement d\'adresse ou de numéro de téléphone',
          '• Être disponible ou désigner une personne pour réceptionner la livraison',
          '• Vérifier le contenu de la livraison et signer le bon de livraison',
          '• Signaler tout problème dans les 48 heures suivant la livraison',
          '• Ne pas céder ou transférer ce contrat à une tierce personne sans accord écrit d\'EduP@y',
        ],
      ),
      const ContractSection(
        title: 'Article 7 — Frais & Transparence Financière',
        paragraphs: [
          'EduP@y perçoit une commission de service représentant 10 % à 15 % '
              'du montant total collecté. Cette commission couvre les frais de '
              'gestion, de livraison et de fonctionnement du service.',
          'Inclus dans la commission : frais de livraison à domicile, frais de '
              'gestion du dossier, suivi mensuel de l\'épargne, émission des '
              'reçus officiels, service client WhatsApp 7j/7.',
          'Non inclus : frais de transaction Mobile Money (à la charge du '
              'Client), coût des fournitures supplémentaires non prévues au '
              'contrat, frais de déplacement si le Client n\'est pas disponible '
              'à la livraison.',
        ],
      ),
      const ContractSection(
        title: 'Article 8 — Remboursement & Résiliation',
        paragraphs: [
          'Le Client peut demander la résiliation du contrat et le '
              'remboursement de son épargne dans les cas suivants :',
          '• Résiliation volontaire avant commande : 100 % de l\'épargne — '
              'frais de dossier de 500 FCFA déduits — sous 72 heures.',
          '• Résiliation volontaire après commande engagée : épargne restante '
              'après déduction des frais fournisseur engagés — sous 5 jours ouvrables.',
          '• Non-livraison de la part d\'EduP@y : 100 % de l\'épargne sans '
              'frais de dossier — sous 48 heures.',
          '• Livraison non conforme (article manquant/défectueux) : '
              'remboursement ou remplacement de l\'article concerné — sous 48 heures.',
          '• Force majeure (catastrophe, décès, etc.) : 100 % de l\'épargne '
              'sans frais — sous 72 heures.',
          'Toute demande de résiliation doit être faite par écrit (WhatsApp, '
              'SMS ou courrier) et confirmée par EduP@y dans les 24 heures.',
        ],
      ),
      const ContractSection(
        title: 'Article 9 — Confidentialité & Protection des Données',
        paragraphs: [
          'EduP@y s\'engage à ne jamais vendre, céder ou communiquer à des '
              'tiers les informations personnelles du Client (nom, numéro de '
              'téléphone, adresse, informations sur les enfants) sans son '
              'accord explicite.',
          'Les données collectées sont utilisées exclusivement pour la '
              'gestion du service EduP@y et l\'amélioration de la qualité des '
              'prestations.',
          'Le Client autorise EduP@y à le contacter par WhatsApp ou SMS pour '
              'les communications liées à son contrat (rappels de cotisation, '
              'confirmations de paiement, informations de livraison).',
        ],
      ),
      const ContractSection(
        title: 'Article 10 — Litiges & Règlement Amiable',
        paragraphs: [
          'En cas de litige entre les parties, celles-ci s\'engagent à '
              'rechercher en priorité une solution amiable dans un délai de 15 '
              'jours suivant la notification du différend.',
          'Si aucun accord n\'est trouvé à l\'amiable, les parties peuvent '
              'faire appel à une médiation communautaire ou soumettre le '
              'litige aux instances compétentes de Ouagadougou.',
          'EduP@y garantit que le Client pourra toujours récupérer son '
              'épargne, même en cas de litige, dans les conditions définies à '
              'l\'Article 8.',
        ],
      ),
      const ContractSection(
        title: 'Article 11 — Dispositions Finales',
        paragraphs: [
          '• Le présent contrat entre en vigueur à la date d\'acceptation par le Client dans l\'application.',
          '• Il reste valable jusqu\'à la livraison complète des fournitures ou jusqu\'à résiliation.',
          '• Toute modification doit faire l\'objet d\'un avenant écrit accepté par les deux parties.',
          '• Le présent contrat est régi par le droit burkinabè en vigueur.',
          '• En acceptant ce contrat, le Client reconnaît avoir lu et compris toutes les conditions générales.',
        ],
      ),
      const ContractSection(
        title: '📌 Ce que vous devez retenir',
        paragraphs: [
          '✅ Votre argent est en sécurité — chaque franc cotisé est enregistré et vous recevez un reçu officiel.',
          '✅ Vous pouvez arrêter à tout moment — remboursement intégral possible, moins 500 FCFA de frais de dossier.',
          '✅ Livraison à domicile garantie — vos fournitures arrivent chez vous avant la rentrée.',
          '✅ Transparence totale — relevé mensuel de votre épargne envoyé chaque mois sur WhatsApp.',
          '✅ Service client disponible 7j/7 sur WhatsApp.',
        ],
      ),
      ContractSection(
        title: 'Annexe — Plan de cotisation personnalisé',
        paragraphs: [
          'Cette annexe fait partie intégrante du contrat. Elle précise le '
              'plan de cotisation choisi et les engagements financiers du Client.',
          'Plan de cotisation choisi : ${plan.title}',
          'Montant par cotisation : ${_money(installmentAmount)} FCFA / ${plan.period}',
          'Objectif total : ${_money(totalGoal)} FCFA',
          'Simulation d\'épargne basée sur ce plan :\n'
              '  • Après 1 échéance : ${_money(after1)} FCFA\n'
              '  • Après 2 échéances : ${_money(after2)} FCFA\n'
              '  • Après 3 échéances : ${_money(after3)} FCFA\n'
              '  • Objectif atteint au plus tard le : ${_formatDate(kSubscriptionDeadline)}',
        ],
      ),
      ContractSection(
        title: 'Acceptation',
        paragraphs: [
          'Conformément à l\'Article 11, l\'acceptation de ce contrat se fait '
              'directement dans l\'application EduP@y : en cochant la case '
              '« J\'ai vérifié les montants et j\'accepte les conditions » puis '
              'en confirmant, le Client${clientName?.isNotEmpty ?? false ? ' ($clientName)' : ''} '
              'reconnaît avoir lu, compris et accepté l\'ensemble des '
              'conditions générales du présent contrat EduP@y ($contractNumber, '
              '${_formatDate(today)}).',
        ],
      ),
    ],
  );
}
