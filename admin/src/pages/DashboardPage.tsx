import { useEffect, useState } from 'react';
import {
  getAllRequests,
  getContributions,
  getPendingRequests,
  getUsers,
} from '../services/api';

interface Stats {
  pendingRequests: number;
  totalRequests: number;
  members: number;
  contributions: number;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats>({
    pendingRequests: 0,
    totalRequests: 0,
    members: 0,
    contributions: 0,
  });
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([
      getPendingRequests(),
      getAllRequests(),
      getUsers(),
      getContributions(),
    ])
      .then(([pending, allRequests, users, contributions]) => {
        setStats({
          pendingRequests: pending.length,
          totalRequests: allRequests.length,
          members: users.filter((user) => user.role === 'member').length,
          contributions: contributions.length,
        });
      })
      .catch((err) => {
        setError(err?.response?.data?.message ?? 'Unable to load dashboard data');
      });
  }, []);

  return (
    <section>
      <header className="page-header">
        <div>
          <h2>Dashboard</h2>
          <p>Review platform activity and urgent administrative tasks.</p>
        </div>
      </header>

      {error && <div className="error-banner">{error}</div>}

      <div className="stats-grid">
        <article className="stat-card">
          <span>Pending requests</span>
          <strong>{stats.pendingRequests}</strong>
        </article>
        <article className="stat-card">
          <span>Total requests</span>
          <strong>{stats.totalRequests}</strong>
        </article>
        <article className="stat-card">
          <span>Members</span>
          <strong>{stats.members}</strong>
        </article>
        <article className="stat-card">
          <span>Contributions</span>
          <strong>{stats.contributions}</strong>
        </article>
      </div>

      <div className="notice-card">
        <h3>Administrator checklist</h3>
        <p>
          Verify supporting documents, confirm the emergency need, approve or reject
          the request, and maintain a clear audit trail before funds are distributed.
        </p>
      </div>
    </section>
  );
}
