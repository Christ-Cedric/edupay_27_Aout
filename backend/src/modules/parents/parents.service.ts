import { prisma } from '../../shared/prisma.js';
import { ApiError } from '../../shared/http/api-error.js';
import { writeAudit } from '../../shared/audit/audit.js';
import { toUserDto } from '../auth/auth.serializer.js';
import type { UpdateProfileInput } from './parents.schemas.js';

/**
 * Met à jour le profil self-service (nom/ville/quartier) d'un parent — les
 * identifiants (téléphone/mot de passe) restent gérés par `PATCH /auth/me`,
 * générique aux 3 rôles.
 */
export async function updateProfile(userId: string, input: UpdateProfileInput) {
  const existing = await prisma.user.findFirst({ where: { id: userId, role: 'client' } });
  if (!existing) throw ApiError.notFound('Compte introuvable.');

  const updated = await prisma.$transaction(async (tx) => {
    const u = await tx.user.update({
      where: { id: userId },
      data: {
        ...(input.full_name !== undefined ? { fullName: input.full_name } : {}),
        ...(input.city !== undefined ? { city: input.city } : {}),
        ...(input.district !== undefined ? { district: input.district } : {}),
      },
    });
    await writeAudit(tx, {
      actorId: userId,
      action: 'family.profile_updated',
      entity: 'user',
      entityId: userId,
      before: { fullName: existing.fullName, city: existing.city, district: existing.district },
      after: { fullName: u.fullName, city: u.city, district: u.district },
    });
    return u;
  });

  return toUserDto(updated);
}
