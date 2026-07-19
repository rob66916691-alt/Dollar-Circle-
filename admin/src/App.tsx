import { BrowserRouter, Route, Routes } from 'react-router-dom';
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';
import ContributionsPage from './pages/ContributionsPage';
import DashboardPage from './pages/DashboardPage';
import LoginPage from './pages/LoginPage';
import MembersPage from './pages/MembersPage';
import RequestsPage from './pages/RequestsPage';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          element={
            <ProtectedRoute>
              <Layout />
            </ProtectedRoute>
          }
        >
          <Route index element={<DashboardPage />} />
          <Route path="/requests" element={<RequestsPage />} />
          <Route path="/members" element={<MembersPage />} />
          <Route path="/contributions" element={<ContributionsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
