# BATWA - Production-Ready Digital E-Wallet

BATWA is a secure, full-stack, cross-platform digital wallet solution engineered with strict financial invariants, zero-trust security, and Clean Architecture.

---

## Architecture Overview

- **Mobile Client:** Flutter (Dart 3.x) targeting iOS & Android.
- **State Management & Pattern:** BLoC / Cubit pattern with Clean Architecture (Presentation, Domain, Data layers).
- **Backend Service:** Spring Boot 3.x (Java 17+) REST API.
- **Database:** PostgreSQL 15+ with strict relational ACID constraints and `CHECK (balance >= 0)`.
- **Security:** Stateless JWT (Access + Refresh tokens), BCrypt hashed transaction PINs with lockout protection, and `Idempotency-Key` header handling.

---

## 1. Database Schema & Financial Invariants

The relational schema is configured in [`backend/src/main/resources/schema.sql`](backend/src/main/resources/schema.sql):

- **Zero-Balance Invariant:** Enforced via `CONSTRAINT chk_wallet_balance_non_negative CHECK (balance >= 0)`.
- **Deadlock-Free Pessimistic Locking:** When executing P2P transfers between Wallet A and Wallet B, wallets are locked via `SELECT ... FOR UPDATE` ordered by primary key UUID (`min(idA, idB)` first, then `max(idA, idB)`).
- **Immutable Ledger:** Every balance mutation produces an audit log in the `transactions` table.
- **Idempotency Guarantee:** Prevents duplicate debits on network retries via `idempotency_records`.

---

## 2. Quick Start & Local Setup

### Step 1: Start PostgreSQL

Run PostgreSQL using Docker Compose:

```bash
docker-compose up -d
```

Database connection parameters:
- **Host:** `localhost:5432`
- **Database:** `batwa_db`
- **Username:** `postgres`
- **Password:** `postgrespassword`

---

### Step 2: Start Spring Boot Backend

From the project root:

```bash
cd backend
./mvnw spring-boot:run
```

Backend will boot up on `http://localhost:8080/api/v1`.

#### Running Backend Unit Tests:

```bash
cd backend
./mvnw test
```

---

### Step 3: Run Flutter Mobile Client

From the project root:

```bash
cd mobile
flutter pub get
flutter run
```

> **Note on Emulator Network:** Android emulators use `http://10.0.2.2:8080/api/v1` to access localhost, which is preconfigured in `lib/core/constants/api_constants.dart`. For iOS simulator or web, use `http://localhost:8080/api/v1`.

---

## 3. Core API Endpoints

| Method | Endpoint | Description | Headers |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Register new account & auto-provision wallet | - |
| `POST` | `/api/v1/auth/login` | Login and obtain JWT tokens | - |
| `POST` | `/api/v1/auth/pin` | Setup or update 4-6 digit Transaction PIN | `Authorization: Bearer <token>` |
| `GET` | `/api/v1/wallets/me` | Fetch real-time balance & wallet tag | `Authorization: Bearer <token>` |
| `GET` | `/api/v1/wallets/lookup?identifier=@tag` | Validate recipient before transferring | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/wallets/topup` | Top-up simulated funds | `Authorization`, `Idempotency-Key` |
| `POST` | `/api/v1/wallets/transfer` | Execute atomic P2P transfer with PIN | `Authorization`, `Idempotency-Key` |
| `GET` | `/api/v1/transactions` | Paginated transaction audit ledger | `Authorization: Bearer <token>` |
| `GET` | `/api/v1/transactions/{refNumber}` | Detailed transaction receipt | `Authorization: Bearer <token>` |

---

## 4. Mobile Clean Architecture Hierarchy

```
mobile/lib/
├── core/
│   ├── constants/ (api_constants.dart, app_colors.dart, app_theme.dart)
│   ├── network/ (api_client.dart, api_exception.dart)
│   └── utils/ (currency_formatters.dart, secure_storage_helper.dart)
├── features/
│   ├── auth/ (Presentation: BLoC + Login/Register/PIN Screens, Domain: Entities/Repo, Data: Models/Datasources)
│   ├── wallet/ (Presentation: BLoC + Dashboard/QR/TopUp/Ledger, Domain: Entities/Repo, Data: Models/Datasources)
│   └── transfer/ (Presentation: BLoC + Send Money/PIN Modal/Receipt, Domain: Entities/Repo, Data: Models/Datasources)
└── main.dart
```
