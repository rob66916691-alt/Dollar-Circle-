import { useEffect, useState } from 'react';
import { getUsers, setUserActive } from '../services/api';
import type { User } from '../types';

export default function MembersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    getUsers()
      .then(setUsers)
      .catch((err) =>
        setError(err?.response?.data?.message ?? 'Unable to load members'),
      );
  }, []);

  async function toggle(user: User) {
    try {
      const updated = await setUserActive(user.id, !user.isActive);
      setUsers((current) =>
        current.map((item) => (item.id === user.id ? updated : item)),
      );
    } catch (err: any) {
      setError(err?.response?.data?.message ?? 'Unable to update member');
    }
  }

  return (
    <section>
      <header className="page-header">
        <div>
          <h2>Members</h2>
          <p>Review registered users and suspend or restore account access.</p>
        </div>
      </header>

      {error && <div className="error-banner">{error}</div>}

      <div className="table-card">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Account</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id}>
                <td>{[user.firstName, user.lastName].filter(Boolean).join(' ') || '—'}</td>
                <td>{user.email}</td>
                <td>{user.role}</td>
                <td>{user.isActive ? 'Active' : 'Suspended'}</td>
                <td>
                  <button className="secondary-button" onClick={() => toggle(user)}>
                    {user.isActive ? 'Suspend' : 'Restore'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
