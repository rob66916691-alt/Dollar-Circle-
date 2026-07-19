import { useEffect, useState } from 'react';
import { getAllRequests, updateRequestStatus } from '../services/api';
import type { AssistanceRequest, RequestStatus } from '../types';

export default function RequestsPage() {
  const [requests, setRequests] = useState<AssistanceRequest[]>([]);
  const [error, setError] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);

  async function load() {
    try {
      setRequests(await getAllRequests());
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Unable to load requests');
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function changeStatus(id: string, status: RequestStatus) {
    setBusyId(id);
    try {
      const updated = await updateRequestStatus(id, status);
      setRequests((current) =>
        current.map((request) => (request.id === id ? updated : request)),
      );
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Unable to update request');
    } finally {
      setBusyId(null);
    }
  }

  return (
    <section>
      <header className="page-header">
        <div>
          <h2>Assistance Requests</h2>
          <p>Review, approve, reject, and monitor member requests.</p>
        </div>
      </header>

      {error && <div className="error-banner">{error}</div>}

      <div className="table-card">
        <table>
          <thead>
            <tr>
              <th>Request</th>
              <th>Amount</th>
              <th>Status</th>
              <th>Submitted</th>
              <th>Decision</th>
            </tr>
          </thead>
          <tbody>
            {requests.map((request) => (
              <tr key={request.id}>
                <td>
                  <strong>{request.title}</strong>
                  <p>{request.description}</p>
                </td>
                <td>${Number(request.amountRequested).toFixed(2)}</td>
                <td>
                  <span className={`status status-${request.status}`}>
                    {request.status}
                  </span>
                </td>
                <td>
                  {request.createdAt
                    ? new Date(request.createdAt).toLocaleDateString()
                    : '—'}
                </td>
                <td>
                  <div className="action-row">
                    <button
                      className="approve-button"
                      disabled={busyId === request.id}
                      onClick={() => changeStatus(request.id, 'approved')}
                    >
                      Approve
                    </button>
                    <button
                      className="reject-button"
                      disabled={busyId === request.id}
                      onClick={() => changeStatus(request.id, 'rejected')}
                    >
                      Reject
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {requests.length === 0 && <div className="empty-state">No requests found.</div>}
      </div>
    </section>
  );
}
