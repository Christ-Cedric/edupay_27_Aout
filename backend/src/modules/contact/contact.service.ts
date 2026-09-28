import { prisma } from '../../shared/prisma.js';
import type { ContactInquiryInput } from './contact.schemas.js';

export async function submitContactInquiry(input: ContactInquiryInput, ip?: string, userAgent?: string) {
  // Détection anti-bot : si le honeypot est rempli, on feint le succès sans enregistrer en base
  if (input.honeypot && input.honeypot.trim().length > 0) {
    return { success: true, message: 'Demande enregistrée avec succès.' };
  }

  // 1. Enregistrement immuable dans audit_logs
  await prisma.auditLog.create({
    data: {
      actorId: 'public_prospect',
      action: 'contact_inquiry_submitted',
      entity: 'contact_inquiry',
      after: {
        name: input.name,
        phone: input.phone,
        profile: input.profile,
        message: input.message,
        ip: ip ?? null,
        userAgent: userAgent ?? null,
      },
    },
  });

  // 2. Notification persistée pour l'administrateur
  const admin = await prisma.user.findFirst({
    where: { role: 'admin' },
    select: { id: true },
  });

  if (admin) {
    const profileLabels: Record<string, string> = {
      parent: "Parent d'élève / tuteur",
      ecole: 'Direction établissement scolaire',
      agent: 'Candidat agent de proximité',
      partenaire: 'Partenaire institutionnel',
    };

    const label = profileLabels[input.profile] || input.profile;

    await prisma.notification.create({
      data: {
        userId: admin.id,
        type: 'contact_inquiry',
        title: `Nouveau contact web : ${input.name} (${label})`,
        body: `Téléphone : ${input.phone}\nMessage : ${input.message.slice(0, 300)}`,
        channel: 'inApp',
      },
    });
  }

  return {
    success: true,
    message: 'Votre demande a été enregistrée avec succès auprès du secrétariat général EduPay.',
  };
}
