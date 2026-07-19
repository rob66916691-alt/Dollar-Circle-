# Dollar Circle Admin Dashboard

React + TypeScript administration dashboard for the Dollar Circle MVP.

## Included

- Administrator login
- Role verification
- Dashboard statistics
- Assistance request review
- Approve and reject controls
- Member account management
- Contribution monitoring
- Responsive layout

## Install and run

```bash
npm install
cp .env.example .env
npm run dev
```

On Windows PowerShell, create the environment file with:

```powershell
Copy-Item .env.example .env
```

Open:

```text
http://localhost:5173
```

## API configuration

The default backend address is:

```text
http://localhost:3000/api
```

Change `VITE_API_BASE_URL` in `.env` when the backend is hosted elsewhere.

## Required backend endpoints

The dashboard expects these administrator endpoints:

```text
GET   /api/admin/requests
GET   /api/admin/requests?status=pending
PATCH /api/admin/requests/:id/status
GET   /api/admin/users
PATCH /api/admin/users/:id/status
GET   /api/admin/contributions
```

These admin endpoints are not yet present in the initial backend package. They must be added before the dashboard can load live data.

## Security

The backend must enforce administrator authorization. The browser-side role check improves usability but does not replace server-side authorization.
