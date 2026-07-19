-- Dollar Circle v1 PostgreSQL schema
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TYPE user_role AS ENUM ('member','reviewer','admin','super_admin');
CREATE TYPE user_status AS ENUM ('pending','active','suspended','closed');
CREATE TYPE verification_status AS ENUM ('not_started','pending','verified','failed','expired');
CREATE TYPE request_status AS ENUM ('draft','submitted','under_review','approved','funding','funded','paid','denied','cancelled','expired');
CREATE TYPE request_category AS ENUM ('rent','utilities','medical','transportation','funeral','food','childcare','other');
CREATE TYPE contribution_status AS ENUM ('selected','authorized','processing','succeeded','failed','cancelled','refunded');
CREATE TYPE transaction_type AS ENUM ('contribution_charge','recipient_payout','refund','fee','adjustment');
CREATE TYPE transaction_status AS ENUM ('pending','processing','succeeded','failed','cancelled','reversed');
CREATE TYPE notification_channel AS ENUM ('in_app','email','sms','push');
CREATE TYPE notification_status AS ENUM ('queued','sent','delivered','failed','read');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid TEXT UNIQUE,
  email CITEXT NOT NULL UNIQUE,
  phone_e164 TEXT UNIQUE,
  role user_role NOT NULL DEFAULT 'member',
  status user_status NOT NULL DEFAULT 'pending',
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth DATE,
  timezone TEXT NOT NULL DEFAULT 'America/Chicago',
  email_verified_at TIMESTAMPTZ,
  phone_verified_at TIMESTAMPTZ,
  accepted_terms_version TEXT,
  accepted_terms_at TIMESTAMPTZ,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT users_phone_format CHECK (phone_e164 IS NULL OR phone_e164 ~ '^\+[1-9][0-9]{7,14}$')
);

CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  address_line1 TEXT,
  address_line2 TEXT,
  city TEXT,
  state_code CHAR(2),
  postal_code TEXT,
  country_code CHAR(2) NOT NULL DEFAULT 'US',
  profile_photo_url TEXT,
  household_size SMALLINT,
  monthly_contribution_limit_cents INTEGER NOT NULL DEFAULT 1000,
  contribution_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  contribution_paused_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (household_size IS NULL OR household_size > 0),
  CHECK (monthly_contribution_limit_cents BETWEEN 0 AND 100000)
);

CREATE TABLE identity_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  provider_reference_id TEXT NOT NULL UNIQUE,
  status verification_status NOT NULL DEFAULT 'not_started',
  risk_level TEXT,
  failure_reason TEXT,
  submitted_at TIMESTAMPTZ,
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE payment_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  provider_customer_id TEXT,
  provider_account_id TEXT NOT NULL UNIQUE,
  account_type TEXT NOT NULL,
  account_last4 CHAR(4),
  institution_name TEXT,
  status verification_status NOT NULL DEFAULT 'pending',
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX payment_accounts_one_default_per_user ON payment_accounts(user_id) WHERE is_default = TRUE;

CREATE TABLE assistance_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  category request_category NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  requested_amount_cents INTEGER NOT NULL CHECK (requested_amount_cents > 0),
  approved_amount_cents INTEGER CHECK (approved_amount_cents IS NULL OR approved_amount_cents > 0),
  funded_amount_cents INTEGER NOT NULL DEFAULT 0 CHECK (funded_amount_cents >= 0),
  status request_status NOT NULL DEFAULT 'draft',
  urgency_score SMALLINT NOT NULL DEFAULT 0 CHECK (urgency_score BETWEEN 0 AND 100),
  due_date DATE,
  submitted_at TIMESTAMPTZ,
  review_started_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  funding_started_at TIMESTAMPTZ,
  funded_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  denied_at TIMESTAMPTZ,
  denial_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX assistance_requests_status_created_idx ON assistance_requests(status, created_at);
CREATE INDEX assistance_requests_requester_idx ON assistance_requests(requester_id, created_at DESC);

CREATE TABLE request_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES assistance_requests(id) ON DELETE CASCADE,
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  document_type TEXT NOT NULL,
  storage_provider TEXT NOT NULL,
  storage_key TEXT NOT NULL UNIQUE,
  original_filename TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size_bytes BIGINT NOT NULL CHECK (size_bytes > 0),
  sha256_hex CHAR(64),
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE request_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES assistance_requests(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  decision TEXT NOT NULL CHECK (decision IN ('approve','deny','needs_information')),
  recommended_amount_cents INTEGER CHECK (recommended_amount_cents IS NULL OR recommended_amount_cents > 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE contribution_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES assistance_requests(id) ON DELETE CASCADE,
  contributor_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  amount_cents INTEGER NOT NULL DEFAULT 100 CHECK (amount_cents > 0),
  status contribution_status NOT NULL DEFAULT 'selected',
  selection_batch UUID NOT NULL DEFAULT gen_random_uuid(),
  selected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  authorization_expires_at TIMESTAMPTZ,
  authorized_at TIMESTAMPTZ,
  processed_at TIMESTAMPTZ,
  failure_code TEXT,
  failure_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (request_id, contributor_id)
);
CREATE INDEX contribution_assignments_contributor_status_idx ON contribution_assignments(contributor_id,status,selected_at DESC);
CREATE INDEX contribution_assignments_request_status_idx ON contribution_assignments(request_id,status);

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  request_id UUID REFERENCES assistance_requests(id) ON DELETE SET NULL,
  contribution_assignment_id UUID REFERENCES contribution_assignments(id) ON DELETE SET NULL,
  payment_account_id UUID REFERENCES payment_accounts(id) ON DELETE SET NULL,
  type transaction_type NOT NULL,
  status transaction_status NOT NULL DEFAULT 'pending',
  amount_cents INTEGER NOT NULL CHECK (amount_cents <> 0),
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  provider TEXT NOT NULL,
  provider_transaction_id TEXT UNIQUE,
  idempotency_key TEXT NOT NULL UNIQUE,
  failure_code TEXT,
  failure_message TEXT,
  initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  settled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX transactions_request_idx ON transactions(request_id,created_at DESC);
CREATE INDEX transactions_user_idx ON transactions(user_id,created_at DESC);
CREATE INDEX transactions_status_idx ON transactions(status,created_at);

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  channel notification_channel NOT NULL,
  status notification_status NOT NULL DEFAULT 'queued',
  template_key TEXT NOT NULL,
  subject TEXT,
  body TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  scheduled_for TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sent_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  failure_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX notifications_user_created_idx ON notifications(user_id,created_at DESC);
CREATE INDEX notifications_queue_idx ON notifications(status,scheduled_for);

CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  actor_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT,
  request_id TEXT,
  ip_address INET,
  user_agent TEXT,
  before_state JSONB,
  after_state JSONB,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX audit_logs_entity_idx ON audit_logs(entity_type,entity_id,created_at DESC);
CREATE INDEX audit_logs_actor_idx ON audit_logs(actor_user_id,created_at DESC);

CREATE TABLE system_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO system_settings (key,value,description) VALUES
('contribution.default_amount_cents','100'::jsonb,'Default contribution amount in cents.'),
('contribution.max_monthly_amount_cents','1000'::jsonb,'Default monthly contribution cap.'),
('request.max_amount_cents','500000'::jsonb,'Maximum Version 1 request amount.'),
('request.minimum_account_age_days','30'::jsonb,'Minimum membership age before requesting help.');

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_set_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER user_profiles_set_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER identity_verifications_set_updated_at BEFORE UPDATE ON identity_verifications FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER payment_accounts_set_updated_at BEFORE UPDATE ON payment_accounts FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER assistance_requests_set_updated_at BEFORE UPDATE ON assistance_requests FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER contribution_assignments_set_updated_at BEFORE UPDATE ON contribution_assignments FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER transactions_set_updated_at BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE VIEW member_monthly_contribution_totals AS
SELECT contributor_id AS user_id,
       date_trunc('month',COALESCE(processed_at,selected_at)) AS contribution_month,
       SUM(amount_cents) FILTER (WHERE status IN ('authorized','processing','succeeded')) AS committed_amount_cents,
       COUNT(*) FILTER (WHERE status='succeeded') AS successful_contribution_count
FROM contribution_assignments
GROUP BY contributor_id,date_trunc('month',COALESCE(processed_at,selected_at));

CREATE VIEW request_funding_progress AS
SELECT ar.id AS request_id, ar.category, ar.title, ar.status,
       COALESCE(ar.approved_amount_cents,ar.requested_amount_cents) AS goal_amount_cents,
       COALESCE(SUM(ca.amount_cents) FILTER (WHERE ca.status='succeeded'),0) AS collected_amount_cents,
       COUNT(ca.id) FILTER (WHERE ca.status='succeeded') AS successful_contributions
FROM assistance_requests ar
LEFT JOIN contribution_assignments ca ON ca.request_id=ar.id
GROUP BY ar.id;
