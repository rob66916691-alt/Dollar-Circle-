import { FormEvent, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminLogin, getCurrentUser } from '../services/api';

export default function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function submit(event: FormEvent) {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      await adminLogin(email, password);
      const user = await getCurrentUser();
      if (user.role !== 'admin') {
        localStorage.removeItem('admin_access_token');
        throw new Error('This account does not have administrator access.');
      }
      navigate('/', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to sign in');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-page">
      <form className="login-card" onSubmit={submit}>
        <div className="brand-mark">DC</div>
        <h1>Dollar Circle Admin</h1>
        <p>Authorized administrators only</p>

        {error && <div className="error-banner">{error}</div>}

        <label>
          Email
          <input
            type="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
          />
        </label>

        <label>
          Password
          <input
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
          />
        </label>

        <button className="primary-button" disabled={loading}>
          {loading ? 'Signing in...' : 'Sign In'}
        </button>
      </form>
    </div>
  );
}
