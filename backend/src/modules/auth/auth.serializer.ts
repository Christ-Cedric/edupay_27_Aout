import type { User } from '@prisma/client';

/** DTO utilisateur en `snake_case` (contrat §1). Jamais le hash de mot de passe. */
export function toUserDto(user: User) {
  return {
    id: user.id,
    role: user.role,
    full_name: user.fullName,
    phone: user.phone,
    status: user.status,
    city: user.city,
    district: user.district,
    must_change_password: user.mustChangePassword,
    // Motif de rejet — affiché au client sur son écran « compte refusé ».
    rejection_reason: user.rejectionReason,
  };
}
