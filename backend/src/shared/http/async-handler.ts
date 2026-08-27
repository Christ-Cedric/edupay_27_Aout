import type { NextFunction, Request, Response, RequestHandler } from 'express';

/**
 * Enrobe un handler async pour que toute exception soit propagée au middleware
 * d'erreur (Express 4 n'attrape pas les rejets de promesse nativement).
 */
export function asyncHandler(
  handler: (req: Request, res: Response, next: NextFunction) => Promise<unknown>,
): RequestHandler {
  return (req, res, next) => {
    handler(req, res, next).catch(next);
  };
}
