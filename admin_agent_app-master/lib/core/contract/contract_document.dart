import '../../features/families/domain/models/family.dart';
import '../../features/families/domain/models/savings_plan.dart';

const String kSchoolYear = '2026-2027';
final DateTime kSubscriptionDeadline = DateTime(2026, 9, 15);

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
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _money(num value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
  }
  return buffer.toString();
}

/// Construit le contrat officiel personnalisé pour une famille côté Admin —
/// structure et clauses rigoureusement identiques au contrat de l'application Client.
ContractDocument buildContractDocumentFromFamily({
  required Family family,
  DateTime? now,
}) {
  final today = now ?? family.registeredAt;
  final clientName = family.fullName.trim();
  final suffix = (family.familyCode?.isNotEmpty ?? false)
      ? family.familyCode!
      : today.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
  final contractNumber = 'EP-CONT-${today.year}-$suffix';

  final childrenLines = family.children.isEmpty
      ? ['Aucun enfant enregistré pour le moment.']
      : family.children.map((c) {
          final details = <String>[];
          if (c.kitPrice > 0) {
            details.add('Fournitures (${_money(c.kitPrice)} F)');
          }
          if ((c.tuitionAmount ?? 0) > 0) {
            details.add('Scolarité : ${_money(c.tuitionAmount ?? 0)} F');
          }
          if ((c.transportAmount ?? 0) > 0) {
            details.add(
              '${c.transportType ?? "Transport"} : ${_money(c.transportAmount ?? 0)} F',
            );
          }
          final summary = details.isEmpty
              ? 'aucun objectif sélectionné'
              : '${details.join(" + ")} (Total : ${_money(c.totalCost)} FCFA)';
          final school = c.school.isNotEmpty ? c.school : 'Non renseignée';
          final level = c.level.isNotEmpty ? c.level : 'Non renseignée';
          return '${c.firstName} — $school, classe $level — $summary';
        }).toList();

  final planPeriods = SavingsPlan.values
      .map(
        (p) =>
            '${p == family.plan ? '✓ ' : '☐ '}${p.label} — '
            '${_money(p.amount)} FCFA minimum / ${p == SavingsPlan.daily ? "jour" : p == SavingsPlan.weekly ? "semaine" : "mois"}',
      )
      .toList();

  final installmentAmount = family.plan.amount;
  final totalGoal = family.targetAmount;
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
              'Nom & Prénom : ${clientName.isNotEmpty ? clientName : 'Non renseigné'}\n'
              'Téléphone : ${family.phone.isNotEmpty ? family.phone : 'Non renseigné'}\n'
              'Ville / Secteur : ${family.city.isNotEmpty ? family.city : 'Non renseigné'}'
              '${family.district != null && family.district!.isNotEmpty ? ', ${family.district}' : ''}',
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
              'progressive destiné à financer l\'achat de fournitures scolaires, '
              'frais de scolarité et de déplacement pour le(s) enfant(s) désigné(s) ci-dessus, '
              'avec livraison à domicile avant la rentrée scolaire.',
          'EduP@y n\'est pas un établissement financier ou bancaire. Il s\'agit '
              'd\'un service de collecte d\'épargne volontaire et de gestion de commande groupée.',
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
              'commande des fournitures auprès des fournisseurs partenaires et au règlement des frais convenus.',
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
        title: 'Article 4 — Montant Objectif & Prestations',
        paragraphs: [
          'Montant objectif total : ${_money(totalGoal)} FCFA',
          'Date de début de cotisation : ${_formatDate(today)}',
          'Date limite (objectif atteint au plus tard) : '
              '${_formatDate(kSubscriptionDeadline)}',
          'La liste des fournitures et prestations à financer est établie conjointement par '
              'le Client et EduP@y avant le début de la phase de commande. '
              'EduP@y s\'engage à honorer exactement les prestations figurant sur '
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
          '• Conserver l\'épargne collectée exclusivement pour l\'achat des fournitures et frais du Client',
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
          'Plan de cotisation choisi : ${family.plan.label}',
          'Montant par cotisation : ${_money(installmentAmount)} FCFA / ${family.plan == SavingsPlan.daily ? "jour" : family.plan == SavingsPlan.weekly ? "semaine" : "mois"}',
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
              'directement dans l\'application EduP@y. Le Client ($clientName) '
              'reconnaît avoir lu, compris et accepté l\'ensemble des '
              'conditions générales du présent contrat EduP@y ($contractNumber, '
              '${_formatDate(today)}).',
        ],
      ),
    ],
  );
}
