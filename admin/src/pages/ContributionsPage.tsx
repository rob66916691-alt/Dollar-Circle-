import { useEffect, useState } from 'react';
import { getContributions } from '../services/api';
import type { Contribution } from '../types';

export default function ContributionsPage() {
  const [items, setItems] = useState<Contribution[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    getContributions()
      .then(setItems)
      .catch((err) =>
        setError(err?.response?.data?.message ?? 'Unable to load contributions'),
      );
  }, []);

  return (
    <section>
      <header className="page-header">
        <div>
          <h2>Contributions</h2>
          <p>Track contribution records and payment status.</p>
        </div>
      </header>

      {error && <div className="error-banner">{error}</div>}

      <div className="table-card">
        <table>
          <thead>
            <tr>
              <th>Contributor</th>
              <th>Request</th>
              <th>Amount</th>
              <th>Status</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => (
              <tr key={item.id}>
                <td>{item.contributorId}</td>
                <td>{item.requestId}</td>
                <td>${Number(item.amount).toFixed(2)}</td>
                <td>
                  <span className={`status status-${item.status}`}>{item.status}</span>
                </td>
                <td>
                  {item.createdAt
                    ? new Date(item.createdAt).toLocaleDateString()
                    : '—'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {items.length === 0 && (
          <div className="empty-state">No contributions found.</div>
        )}
      </div>
    </section>
  );
}
