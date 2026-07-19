import { Navigate } from 'react-router-dom';
import { hasAdminToken } from '../services/api';

export default function ProtectedRoute({ children }: { children: React.ReactNode }) {
  if (!hasAdminToken()) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}
