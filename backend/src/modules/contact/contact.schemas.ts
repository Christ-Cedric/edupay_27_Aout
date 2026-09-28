import { z } from 'zod';

export const contactInquirySchema = z.object({
  name: z
    .string()
    .trim()
    .min(2, 'Le nom doit comporter au moins 2 caractères.')
    .max(100, 'Le nom ne peut pas dépasser 100 caractères.')
    .transform((val) => val.replace(/<[^>]*>/g, '').trim()),
  phone: z
    .string()
    .trim()
    .regex(/^\+?[0-9\s\-()]{8,20}$/, 'Numéro de téléphone invalide.')
    .transform((val) => val.replace(/[^\d+]/g, '')),
  profile: z.enum(['parent', 'ecole', 'agent', 'partenaire']),
  message: z
    .string()
    .trim()
    .min(5, 'Le message doit comporter au moins 5 caractères.')
    .max(2000, 'Le message ne peut pas dépasser 2000 caractères.')
    .transform((val) => val.replace(/<[^>]*>/g, '').trim()),
  honeypot: z.string().optional().default(''),
});

export type ContactInquiryInput = z.infer<typeof contactInquirySchema>;
