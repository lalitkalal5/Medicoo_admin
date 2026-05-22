# Medicoo Admin Server

Rails admin server for customer licensing, subscription tracking, device binding, and Groq API key inventory.

## Features

- Password-protected admin dashboard with ERB views
- Customer CRUD with auto-generated license keys
- Groq key pool management with encrypted key storage
- Activation, validate, refresh-key, and register-device API endpoints
- Device binding enforcement
- Subscription status tracking and expiring-soon overview
- Rate limiting with `rack-attack`
- Render-ready PostgreSQL deployment setup

## Main Routes

- `POST /api/activate`
- `POST /api/assign-key`
- `POST /api/refresh-key`
- `GET /api/validate`
- `POST /api/register-device`
- `POST /assign-key`
- `POST /refresh-key`
- `GET /validate`
- `GET /login`
- `GET /admin`

## Request / Response Examples

### Assign or activate a key

```bash
curl -X POST https://your-app.onrender.com/api/activate \
  -H "Content-Type: application/json" \
  -d '{
    "license_key": "ABCD-EFGH-IJKL-MNOP",
    "device_identifier": "machine-fingerprint-123",
    "ip_address": "103.10.10.10"
  }'
```

```json
{
  "groq_api_key": "gsk_...",
  "encrypted_groq_api_key": "eyJfcmFpbHMiOnsibWVz...",
  "expiry_date": "2026-06-30",
  "customer_name": "John Doe",
  "status": "active",
  "license_key": "ABCD-EFGH-IJKL-MNOP"
}
```

### Refresh a key

```bash
curl -X POST https://your-app.onrender.com/api/refresh-key \
  -H "Content-Type: application/json" \
  -d '{
    "license_key": "ABCD-EFGH-IJKL-MNOP",
    "device_identifier": "machine-fingerprint-123"
  }'
```

### Validate a license

```bash
curl "https://your-app.onrender.com/api/validate?license_key=ABCD-EFGH-IJKL-MNOP&device_identifier=machine-fingerprint-123"
```

## Data Model

### Customers

- Contact details and address
- Auto-generated `license_key`
- Device fingerprint binding
- Assigned Groq key reference
- Plan type and subscription dates
- Status and notes

### Groq Keys

- Encrypted `api_key`
- Assignment tracking
- Assigned customer and assignment timestamp

### Activation Logs

- Customer
- Groq key used
- Device identifier
- IP address
- Action type
- Activation timestamp

## Local Setup

1. Install gems:

```bash
bundle install
```

2. Copy environment variables:

```bash
cp .env.example .env
```

3. Set these required secrets in `.env`:

- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`
- `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`
- `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`
- `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`
- `LICENSE_RESPONSE_SECRET`

4. Create and migrate the database:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

5. Run the server:

```bash
bundle exec rails server
```

6. Open:

- Admin login: `http://localhost:3000/login`
- Dashboard: `http://localhost:3000/admin`

## Render Deployment

### 1. Create PostgreSQL

- In Render, create a new PostgreSQL instance.
- Copy the internal database URL into `DATABASE_URL`.

### 2. Create Web Service

- Environment: `Ruby`
- Build command: `bundle install && bundle exec rails db:migrate`
- Start command: `bundle exec puma -C config/puma.rb`

### 3. Add Environment Variables

- `RAILS_ENV=production`
- `RAILS_SERVE_STATIC_FILES=true`
- `SECRET_KEY_BASE` from `bundle exec rails secret`
- `DATABASE_URL`
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`
- `APP_HOST=your-app-name.onrender.com`
- `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`
- `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`
- `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`
- `LICENSE_RESPONSE_SECRET`
- `ALLOWED_ORIGINS`
- Optional SMTP variables if you want email alerts

### 4. Optional Render Cron Job

To send expiry alerts once per day, create a Render Cron Job:

```bash
bundle exec rake subscriptions:notify_expiring
```

## Security Notes

- Groq API keys are encrypted at rest via Rails Active Record Encryption.
- Admin login uses environment-backed credentials and secure string comparison.
- API endpoints enforce license key and device identifier matching.
- Rate limiting is enabled by IP and license key.
- Render terminates HTTPS for production traffic.

## Recommended Electron Flow

1. Electron app calls `POST /api/activate` or `POST /assign-key`.
2. Server validates the license and device.
3. Server assigns an unused Groq key if needed.
4. Server returns the key over HTTPS plus an `encrypted_groq_api_key` payload.
5. Client stores the payload locally in encrypted form.
