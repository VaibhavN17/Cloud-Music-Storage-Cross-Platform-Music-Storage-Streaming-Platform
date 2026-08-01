import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';
import { ApiError, ErrorCode } from '../utils/ApiError';

export const validate =
  (schema: AnyZodObject) =>
  async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      return next();
    } catch (error) {
      if (error instanceof ZodError) {
        const formattedErrors = error.errors.map((e) => ({
          field: e.path.join('.').replace(/^body\.|^query\.|^params\./, ''),
          message: e.message,
        }));
        return next(ApiError.badRequest('Validation failed', ErrorCode.VALIDATION_FAILED, formattedErrors));
      }
      return next(error);
    }
  };
