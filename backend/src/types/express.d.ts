import { UserAuthContext } from '../interfaces/auth.interface.js';

declare global {
  namespace Express {
    interface Request {
      user?: UserAuthContext;
    }
  }
}
