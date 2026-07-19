import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { adminLogout } from '../services/api';

export default function Layout() {
  const navigate = useNavigate();

  function logout() {
    adminLogout();
    navigate('/login', { replace: true });
  }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div>
          <h1>Dollar Circle</h1>
          <p>Administration</p>
        </div>

        <nav>
          <NavLink to="/">Dashboard</NavLink>
          <NavLink to="/requests">Requests</NavLink>
          <NavLink to="/members">Members</NavLink>
          <NavLink to="/contributions">Contributions</NavLink>
        </nav>

        <button className="secondary-button" onClick={logout}>
          Sign Out
        </button>
      </aside>

      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}
