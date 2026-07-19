# Dollar Circle MVP Backend

This ZIP contains the first implementation package for Dollar Circle.

## Included
- NestJS REST API
- PostgreSQL and Docker Compose setup
- JWT registration and login
- Current-user endpoint
- Assistance-request creation and history
- Approved-request listing
- Contribution creation and history
- Your PostgreSQL schema

## Run it
1. Install Docker Desktop.
2. Extract this ZIP.
3. Open a terminal in the `Dollar-Circle-MVP` folder.
4. Run `docker compose up --build`.
5. API base URL: `http://localhost:3000/api`.

## Endpoints
- POST `/api/auth/register`
- POST `/api/auth/login`
- GET `/api/users/me`
- POST `/api/requests`
- GET `/api/requests/mine`
- GET `/api/requests/approved`
- POST `/api/contributions`
- GET `/api/contributions/mine`

Protected endpoints require `Authorization: Bearer YOUR_TOKEN`.

## Before production
Align the TypeORM entities with the final SQL schema, add migrations, administrator approval endpoints, payment processing, document storage, rate limiting, audit logging, and tests.
