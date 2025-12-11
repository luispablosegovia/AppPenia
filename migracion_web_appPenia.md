# Plan de Migración: AppPenia iOS → Aplicación Web en la Nube

## Resumen Ejecutivo

Este documento detalla el plan para migrar AppPenia, una aplicación iOS nativa (SwiftUI + SwiftData), a una aplicación web escalable en la nube con autenticación OAuth, sistema multi-tenant y roles de usuario.

**Decisiones del Usuario:**
- ✅ Stack: Python + FastAPI (backend) + React (frontend)
- ✅ Migración de datos existentes desde iOS
- ✅ Funcionalidad completa desde MVP
- ✅ Hosting: Vercel (frontend) + Supabase (DB) + Railway (backend)

---

## 1. Stack Tecnológico Seleccionado

### Arquitectura: Python Backend + React Frontend

| Componente | Tecnología | Justificación |
|------------|------------|---------------|
| **Frontend** | React + Vite + TanStack Query | Rápido, moderno, excelente DX |
| **Backend** | FastAPI (Python 3.11+) | Async, auto-documentación OpenAPI, tipado |
| **Base de Datos** | PostgreSQL (Supabase) | Relacional, RLS para multi-tenant |
| **ORM** | SQLAlchemy 2.0 + Alembic | Maduro, async support, migraciones |
| **Autenticación** | Authlib + FastAPI Users | OAuth flexible (Google, Apple) |
| **Almacenamiento** | Supabase Storage | CDN integrado, tier gratuito |
| **Mapas** | Mapbox GL JS (frontend) + geopy (backend) | Geocodificación completa |
| **Gráficos** | Recharts | Compatible con React |
| **Hosting Frontend** | Vercel | CDN global, deploy automático |
| **Hosting Backend** | Railway | Fácil deploy Python, tier gratuito |
| **PWA** | Vite PWA Plugin | Service workers, offline |

### Ventajas de Python + FastAPI

1. **Algoritmos complejos**: Python ideal para el algoritmo de deudas
2. **Decimal nativo**: Precisión financiera sin librerías extra
3. **Auto-documentación**: Swagger/OpenAPI generado automáticamente
4. **Async/await**: Performance similar a Node.js
5. **Tipado estricto**: Pydantic para validación de datos

---

## 2. Arquitectura de Base de Datos

### 2.1 Diagrama de Entidades

```
accounts (usuarios autenticados)
    │
    ├──► group_memberships ◄── groups (tenants)
    │         │                    │
    │         ▼                    │
    │      members ◄───────────────┘
    │         │
    │         ├──► attendances ◄── events
    │         │                      │
    │         └──► payments ◄── expenses
```

### 2.2 Nuevas Entidades (vs iOS)

| Entidad | Propósito |
|---------|-----------|
| `accounts` | Usuarios autenticados (Google/Apple) |
| `groups` | Grupos independientes (multi-tenant) |
| `group_memberships` | Relación usuario-grupo con rol |
| `group_invitations` | Sistema de invitaciones |

### 2.3 Schema Prisma Completo

```prisma
// Cuenta de usuario autenticado
model Account {
  id            String   @id @default(cuid())
  email         String   @unique
  provider      String   // "google" | "apple"
  providerId    String   @map("provider_id")
  displayName   String?
  avatarUrl     String?
  createdAt     DateTime @default(now())

  memberships   GroupMembership[]
  createdGroups Group[] @relation("GroupCreator")
}

// Grupo de juntadas (tenant)
model Group {
  id          String   @id @default(cuid())
  name        String
  description String?
  inviteCode  String   @unique @default(cuid())
  createdById String
  createdAt   DateTime @default(now())

  createdBy   Account @relation("GroupCreator", fields: [createdById], references: [id])
  memberships GroupMembership[]
  members     Member[]
  events      Event[]
}

// Membresía en grupo
model GroupMembership {
  id        String   @id @default(cuid())
  groupId   String
  accountId String
  role      Role     @default(MEMBER) // ADMIN | MEMBER
  memberId  String?  // Vínculo opcional con Member
  joinedAt  DateTime @default(now())

  group   Group   @relation(fields: [groupId], references: [id], onDelete: Cascade)
  account Account @relation(fields: [accountId], references: [id], onDelete: Cascade)
  member  Member? @relation(fields: [memberId], references: [id])

  @@unique([groupId, accountId])
}

enum Role {
  ADMIN
  MEMBER
}

// Miembro del grupo (equivalente a User en iOS)
model Member {
  id        String    @id @default(cuid())
  groupId   String
  name      String
  birthday  DateTime?
  hasSede   Boolean   @default(false)
  address   String    @default("")
  photoUrl  String?
  latitude  Float?
  longitude Float?
  createdAt DateTime  @default(now())

  group              Group             @relation(fields: [groupId], references: [id], onDelete: Cascade)
  attendances        Attendance[]
  payments           Payment[]
  linkedMemberships  GroupMembership[]
  eventsAsHost       Event[] @relation("EventHost")
  eventsAsCook       Event[] @relation("EventCook")
  eventsAsDishwasher Event[] @relation("EventDishwasher")
}

// Evento/Juntada
model Event {
  id           String   @id @default(cuid())
  groupId      String
  date         DateTime
  notes        String   @default("")
  hostId       String?
  cookId       String?
  dishwasherId String?
  photoUrl     String?
  createdAt    DateTime @default(now())

  group       Group        @relation(fields: [groupId], references: [id], onDelete: Cascade)
  host        Member?      @relation("EventHost", fields: [hostId], references: [id])
  cook        Member?      @relation("EventCook", fields: [cookId], references: [id])
  dishwasher  Member?      @relation("EventDishwasher", fields: [dishwasherId], references: [id])
  attendances Attendance[]
  expense     Expense?
}

// Asistencia
model Attendance {
  id        String   @id @default(cuid())
  memberId  String
  eventId   String
  createdAt DateTime @default(now())

  member Member @relation(fields: [memberId], references: [id], onDelete: Cascade)
  event  Event  @relation(fields: [eventId], references: [id], onDelete: Cascade)

  @@unique([memberId, eventId])
}

// Gasto
model Expense {
  id          String   @id @default(cuid())
  eventId     String   @unique
  totalAmount Decimal  @db.Decimal(12, 2)
  createdAt   DateTime @default(now())

  event    Event     @relation(fields: [eventId], references: [id], onDelete: Cascade)
  payments Payment[]
}

// Pago
model Payment {
  id        String   @id @default(cuid())
  expenseId String
  memberId  String
  amount    Decimal  @db.Decimal(12, 2)
  createdAt DateTime @default(now())

  expense Expense @relation(fields: [expenseId], references: [id], onDelete: Cascade)
  member  Member  @relation(fields: [memberId], references: [id], onDelete: Cascade)
}

// Invitaciones
model GroupInvitation {
  id          String   @id @default(cuid())
  groupId     String
  email       String
  token       String   @unique @default(cuid())
  role        Role     @default(MEMBER)
  expiresAt   DateTime
  createdById String
  createdAt   DateTime @default(now())

  group     Group   @relation(fields: [groupId], references: [id], onDelete: Cascade)
  createdBy Account @relation(fields: [createdById], references: [id])
}
```

---

## 3. Sistema de Autenticación

### 3.1 Flujo OAuth

```
Usuario → React App → FastAPI → Google/Apple → Callback → JWT Token → Frontend Storage
```

### 3.2 Configuración FastAPI con Authlib

```python
# backend/app/auth/oauth.py
from authlib.integrations.starlette_client import OAuth
from fastapi import APIRouter, Depends
from fastapi.responses import RedirectResponse

oauth = OAuth()

oauth.register(
    name='google',
    client_id=settings.GOOGLE_CLIENT_ID,
    client_secret=settings.GOOGLE_CLIENT_SECRET,
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

oauth.register(
    name='apple',
    client_id=settings.APPLE_CLIENT_ID,
    client_secret=settings.APPLE_CLIENT_SECRET,
    authorize_url='https://appleid.apple.com/auth/authorize',
    access_token_url='https://appleid.apple.com/auth/token',
    client_kwargs={'scope': 'name email'}
)

router = APIRouter()

@router.get("/login/{provider}")
async def login(provider: str, request: Request):
    redirect_uri = f"{settings.API_URL}/auth/callback/{provider}"
    return await oauth.create_client(provider).authorize_redirect(request, redirect_uri)

@router.get("/callback/{provider}")
async def callback(provider: str, request: Request, db: AsyncSession = Depends(get_db)):
    client = oauth.create_client(provider)
    token = await client.authorize_access_token(request)
    user_info = token.get('userinfo') or await client.userinfo(token=token)

    # Crear o actualizar cuenta
    account = await get_or_create_account(db, provider, user_info)

    # Generar JWT
    access_token = create_access_token(data={"sub": str(account.id)})

    # Redirect al frontend con token
    return RedirectResponse(f"{settings.FRONTEND_URL}/auth/success?token={access_token}")
```

### 3.3 JWT y Protección de Rutas

```python
# backend/app/auth/jwt.py
from jose import JWTError, jwt
from datetime import datetime, timedelta

def create_access_token(data: dict, expires_delta: timedelta = timedelta(days=7)):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> Account:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        account_id = payload.get("sub")
        if account_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    account = await db.get(Account, account_id)
    if account is None:
        raise credentials_exception
    return account
```

### 3.3 Sistema de Permisos

| Rol | Permisos |
|-----|----------|
| **ADMIN** | CRUD completo de grupo, miembros, eventos, gastos + invitar |
| **MEMBER** | Leer grupo/miembros, CRUD eventos y gastos propios |

---

## 4. API REST Endpoints (FastAPI)

### 4.1 Estructura de Routers

```python
# backend/app/main.py
from fastapi import FastAPI
from app.routers import auth, groups, members, events, expenses, stats

app = FastAPI(title="AppPenia API", version="1.0.0")

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(groups.router, prefix="/groups", tags=["Groups"])
app.include_router(members.router, prefix="/members", tags=["Members"])
app.include_router(events.router, prefix="/events", tags=["Events"])
app.include_router(expenses.router, prefix="/expenses", tags=["Expenses"])
app.include_router(stats.router, prefix="/stats", tags=["Statistics"])
```

### 4.2 Endpoints REST Completos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| **Auth** | | |
| GET | `/auth/login/{provider}` | Iniciar OAuth (google/apple) |
| GET | `/auth/callback/{provider}` | Callback OAuth |
| GET | `/auth/me` | Usuario actual |
| **Groups** | | |
| GET | `/groups` | Listar mis grupos |
| POST | `/groups` | Crear grupo (creador = ADMIN) |
| GET | `/groups/{id}` | Detalle de grupo |
| PUT | `/groups/{id}` | Editar grupo |
| DELETE | `/groups/{id}` | Eliminar grupo |
| POST | `/groups/join/{code}` | Unirse por código |
| **Members** | | |
| GET | `/groups/{gid}/members` | Listar miembros del grupo |
| POST | `/groups/{gid}/members` | Crear miembro |
| GET | `/members/{id}` | Detalle de miembro |
| PUT | `/members/{id}` | Editar miembro |
| DELETE | `/members/{id}` | Eliminar miembro |
| POST | `/members/{id}/photo` | Subir foto |
| **Events** | | |
| GET | `/groups/{gid}/events` | Listar eventos del grupo |
| POST | `/groups/{gid}/events` | Crear evento |
| GET | `/events/{id}` | Detalle de evento |
| PUT | `/events/{id}` | Editar evento |
| DELETE | `/events/{id}` | Eliminar evento |
| POST | `/events/{id}/attendees` | Agregar asistentes |
| DELETE | `/events/{id}/attendees/{mid}` | Quitar asistente |
| **Expenses** | | |
| POST | `/events/{id}/expense` | Crear gasto |
| GET | `/expenses/{id}` | Detalle de gasto |
| DELETE | `/expenses/{id}` | Eliminar gasto |
| GET | `/expenses/{id}/debts` | **Calcular deudas optimizadas** |
| **Stats** | | |
| GET | `/groups/{gid}/stats` | Estadísticas del grupo |
| GET | `/members/{id}/balance` | Balance financiero |
| **Invites** | | |
| POST | `/groups/{gid}/invites` | Enviar invitación |
| GET | `/invites/{token}` | Validar invitación |

---

## 5. Algoritmo de Deudas (Portado de Swift a Python)

### 5.1 Archivo Original iOS
`/Users/manoloacademia/Documents/Swift/AppPenia/AppPenia/Models/Expense.swift` (líneas 63-138)

### 5.2 Implementación Python

```python
# backend/app/services/debt_calculator.py
from decimal import Decimal, ROUND_HALF_UP
from dataclasses import dataclass
from typing import List
from app.models import Member, Expense, Payment

@dataclass
class Debt:
    from_member: Member
    to_member: Member
    amount: Decimal

def calculate_optimized_debts(expense: Expense) -> List[Debt]:
    """
    Algoritmo Greedy para minimizar transacciones de deuda.
    Portado de Swift (AppPenia iOS).
    """
    attendees = [att.member for att in expense.event.attendances]
    payments = expense.payments

    if not attendees:
        return []

    # Usar Decimal nativo de Python para precisión financiera
    total = Decimal(str(expense.total_amount))
    amount_per_person = total / len(attendees)

    # Paso 1: Calcular balance neto por usuario
    balances: dict[str, tuple[Member, Decimal]] = {}

    for member in attendees:
        balances[member.id] = (member, -amount_per_person)  # Empieza debiendo

    for payment in payments:
        if payment.member_id in balances:
            member, balance = balances[payment.member_id]
            balances[payment.member_id] = (member, balance + Decimal(str(payment.amount)))

    # Paso 2: Separar acreedores y deudores
    EPSILON = Decimal("0.01")
    creditors: List[tuple[Member, Decimal]] = []
    debtors: List[tuple[Member, Decimal]] = []

    for member, balance in balances.values():
        if balance > EPSILON:
            creditors.append((member, balance))
        elif balance < -EPSILON:
            debtors.append((member, abs(balance)))

    # Paso 3: Ordenar por monto descendente (optimización greedy)
    creditors.sort(key=lambda x: x[1], reverse=True)
    debtors.sort(key=lambda x: x[1], reverse=True)

    # Paso 4: Emparejar deudores con acreedores
    debts: List[Debt] = []
    i, j = 0, 0

    # Convertir a listas mutables
    creditors_mut = [[c[0], c[1]] for c in creditors]
    debtors_mut = [[d[0], d[1]] for d in debtors]

    while i < len(creditors_mut) and j < len(debtors_mut):
        creditor = creditors_mut[i]
        debtor = debtors_mut[j]

        transfer_amount = min(creditor[1], debtor[1])

        debts.append(Debt(
            from_member=debtor[0],
            to_member=creditor[0],
            amount=transfer_amount.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        ))

        creditor[1] -= transfer_amount
        debtor[1] -= transfer_amount

        if creditor[1] < EPSILON:
            i += 1
        if debtor[1] < EPSILON:
            j += 1

    return debts


# Endpoint que usa el algoritmo
# backend/app/routers/expenses.py
@router.get("/{expense_id}/debts", response_model=List[DebtResponse])
async def get_optimized_debts(
    expense_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: Account = Depends(get_current_user)
):
    expense = await get_expense_with_relations(db, expense_id)
    await check_permission(current_user, expense.event.group_id, "expense:read")

    debts = calculate_optimized_debts(expense)

    return [
        DebtResponse(
            from_member=MemberResponse.from_orm(d.from_member),
            to_member=MemberResponse.from_orm(d.to_member),
            amount=float(d.amount)
        )
        for d in debts
    ]
```

### 5.3 Tests Unitarios

```python
# backend/tests/test_debt_calculator.py
import pytest
from decimal import Decimal
from app.services.debt_calculator import calculate_optimized_debts

def test_simple_debt_case():
    """Juan paga todo, María y Pedro deben."""
    # Setup: 3 personas, gasto $30000, Juan pagó todo
    expense = create_mock_expense(
        total=30000,
        attendees=["Juan", "María", "Pedro"],
        payments=[("Juan", 30000)]
    )

    debts = calculate_optimized_debts(expense)

    assert len(debts) == 2
    # María debe $10000 a Juan
    # Pedro debe $10000 a Juan
    total_to_juan = sum(d.amount for d in debts if d.to_member.name == "Juan")
    assert total_to_juan == Decimal("20000")

def test_minimizes_transactions():
    """Verifica que el algoritmo minimiza transacciones."""
    # 4 personas, 2 pagan más de lo que deben
    expense = create_mock_expense(
        total=40000,
        attendees=["A", "B", "C", "D"],  # Cada uno debe $10000
        payments=[("A", 25000), ("B", 15000)]  # A: +15000, B: +5000
    )

    debts = calculate_optimized_debts(expense)

    # Sin optimización: C→A, C→B, D→A, D→B (4 transacciones)
    # Con optimización: máximo 2-3 transacciones
    assert len(debts) <= 3
```

---

## 6. Estructura del Proyecto Web

### 6.1 Monorepo con Backend y Frontend Separados

```
apppenia-web/
├── backend/                          # FastAPI Python
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                   # Entry point FastAPI
│   │   ├── config.py                 # Settings (env vars)
│   │   ├── database.py               # SQLAlchemy async setup
│   │   ├── models/                   # SQLAlchemy models
│   │   │   ├── __init__.py
│   │   │   ├── account.py
│   │   │   ├── group.py
│   │   │   ├── member.py
│   │   │   ├── event.py
│   │   │   ├── expense.py
│   │   │   └── payment.py
│   │   ├── schemas/                  # Pydantic schemas
│   │   │   ├── __init__.py
│   │   │   ├── account.py
│   │   │   ├── group.py
│   │   │   ├── member.py
│   │   │   ├── event.py
│   │   │   └── expense.py
│   │   ├── routers/                  # API endpoints
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   ├── groups.py
│   │   │   ├── members.py
│   │   │   ├── events.py
│   │   │   ├── expenses.py
│   │   │   └── stats.py
│   │   ├── services/                 # Business logic
│   │   │   ├── __init__.py
│   │   │   ├── debt_calculator.py    # Algoritmo de deudas
│   │   │   ├── geocoding.py          # geopy integration
│   │   │   └── storage.py            # Supabase Storage
│   │   └── auth/                     # Authentication
│   │       ├── __init__.py
│   │       ├── oauth.py              # Google/Apple OAuth
│   │       ├── jwt.py                # JWT tokens
│   │       └── permissions.py        # RBAC
│   ├── migrations/                   # Alembic migrations
│   │   ├── versions/
│   │   └── env.py
│   ├── tests/                        # pytest tests
│   │   ├── test_debt_calculator.py
│   │   ├── test_auth.py
│   │   └── test_api.py
│   ├── scripts/
│   │   └── migrate_ios_data.py       # Script migración iOS
│   ├── requirements.txt
│   ├── Dockerfile
│   └── railway.toml                  # Deploy config
│
├── frontend/                         # React + Vite
│   ├── src/
│   │   ├── main.tsx
│   │   ├── App.tsx
│   │   ├── api/                      # API client (axios/fetch)
│   │   │   ├── client.ts
│   │   │   ├── auth.ts
│   │   │   ├── groups.ts
│   │   │   ├── members.ts
│   │   │   ├── events.ts
│   │   │   └── expenses.ts
│   │   ├── pages/                    # Route pages
│   │   │   ├── auth/
│   │   │   │   ├── SignIn.tsx
│   │   │   │   └── AuthCallback.tsx
│   │   │   ├── groups/
│   │   │   │   ├── GroupList.tsx
│   │   │   │   ├── GroupDetail.tsx
│   │   │   │   └── GroupSettings.tsx
│   │   │   ├── events/
│   │   │   │   ├── EventList.tsx
│   │   │   │   ├── EventDetail.tsx
│   │   │   │   └── EventForm.tsx
│   │   │   ├── members/
│   │   │   │   ├── MemberList.tsx
│   │   │   │   ├── MemberProfile.tsx
│   │   │   │   └── MemberForm.tsx
│   │   │   ├── expenses/
│   │   │   │   ├── ExpenseList.tsx
│   │   │   │   ├── ExpenseDetail.tsx
│   │   │   │   └── ExpenseForm.tsx
│   │   │   └── stats/
│   │   │       └── Statistics.tsx
│   │   ├── components/
│   │   │   ├── ui/                   # Base components
│   │   │   ├── glass/                # Glassmorphism
│   │   │   │   ├── GlassBackground.tsx
│   │   │   │   ├── GlassCard.tsx
│   │   │   │   └── GlassButton.tsx
│   │   │   ├── charts/               # Recharts
│   │   │   │   ├── AttendanceChart.tsx
│   │   │   │   ├── RoleStatsChart.tsx
│   │   │   │   └── ExpensesChart.tsx
│   │   │   ├── maps/
│   │   │   │   └── SedeMap.tsx       # Mapbox GL
│   │   │   └── layout/
│   │   │       ├── Navbar.tsx
│   │   │       ├── Sidebar.tsx
│   │   │       └── TabNav.tsx
│   │   ├── hooks/                    # Custom hooks
│   │   │   ├── useAuth.ts
│   │   │   ├── useGroups.ts
│   │   │   └── usePermissions.ts
│   │   ├── stores/                   # Zustand stores
│   │   │   ├── authStore.ts
│   │   │   └── groupStore.ts
│   │   └── styles/
│   │       └── globals.css           # Tailwind
│   ├── public/
│   ├── index.html
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── tsconfig.json
│   └── package.json
│
├── docker-compose.yml                # Dev environment
├── .env.example
└── README.md
```

---

## 7. Mapeo de Componentes iOS → Web

| iOS (SwiftUI) | Web (React) | Librería |
|---------------|-------------|----------|
| `SedeMapView` | `<SedeMap>` | Mapbox GL JS |
| `ProfilePhotoView` | `<Avatar>` | shadcn/ui |
| `GlassBackground` | `<GlassBackground>` | Tailwind CSS |
| `GlassCard` | `<GlassCard>` | Tailwind CSS |
| SwiftUI Charts | `<BarChart>` | Recharts |
| `CameraView` | `<input type="file">` + Cloudinary |

---

## 8. Fases de Implementación

### Fase 1: Foundation (Setup)
- [ ] Crear proyecto Next.js 14 con App Router
- [ ] Configurar Prisma + Supabase PostgreSQL
- [ ] Implementar NextAuth.js (Google + Apple)
- [ ] Schema de BD + migraciones iniciales
- [ ] Estructura de carpetas

### Fase 2: Core Multi-Tenant
- [ ] CRUD Grupos
- [ ] Sistema de invitaciones (código + email)
- [ ] Membresías y roles (ADMIN/MEMBER)
- [ ] Middleware de permisos
- [ ] Row Level Security en Supabase

### Fase 3: Funcionalidades Principales
- [ ] CRUD Miembros (sin fotos inicialmente)
- [ ] CRUD Eventos
- [ ] Sistema de Asistencias
- [ ] Asignación de roles (host, cook, dishwasher)

### Fase 4: Sistema de Gastos
- [ ] CRUD Gastos
- [ ] Múltiples pagadores
- [ ] Portar algoritmo de deudas (Decimal.js)
- [ ] Balance financiero por usuario
- [ ] Tests unitarios del algoritmo

### Fase 5: Integraciones
- [ ] Upload de fotos (Cloudinary)
- [ ] Mapas con Mapbox GL JS
- [ ] Geocodificación de direcciones
- [ ] 4 gráficos de estadísticas (Recharts)

### Fase 6: UI/UX
- [ ] Diseño Glassmorphism (Tailwind)
- [ ] Responsive design
- [ ] Animaciones y transiciones
- [ ] Dark/Light mode

### Fase 7: PWA y Deploy
- [ ] Configurar next-pwa
- [ ] Service workers
- [ ] Deploy en Vercel
- [ ] Configurar dominio

### Fase 8: Testing y QA
- [ ] Tests unitarios (Vitest)
- [ ] Tests E2E (Playwright)
- [ ] Pruebas de carga
- [ ] Fix bugs

---

## 9. Archivos Críticos del Proyecto iOS

Estos archivos contienen la lógica que debe portarse:

| Archivo | Líneas | Contenido Crítico |
|---------|--------|-------------------|
| `Models/Expense.swift` | 63-138 | Algoritmo de deudas |
| `Models/User.swift` | Completo | Propiedades de miembro |
| `Models/Event.swift` | Completo | Roles y relaciones |
| `Components/SedeMapView.swift` | Completo | Lógica de geocodificación |
| `Views/StatisticsView.swift` | Completo | 4 tipos de gráficos |

---

## 10. Variables de Entorno Requeridas

```env
# Base de datos
DATABASE_URL="postgresql://..."

# Autenticación
NEXTAUTH_SECRET="..."
NEXTAUTH_URL="https://tu-dominio.com"

# Google OAuth
GOOGLE_CLIENT_ID="..."
GOOGLE_CLIENT_SECRET="..."

# Apple OAuth
APPLE_ID="..."
APPLE_SECRET="..."

# Mapbox
NEXT_PUBLIC_MAPBOX_TOKEN="..."

# Cloudinary
CLOUDINARY_CLOUD_NAME="..."
CLOUDINARY_API_KEY="..."
CLOUDINARY_API_SECRET="..."
```

---

## 11. Migración de Datos desde iOS

### 11.1 Paso 1: Exportar datos desde iOS

Agregar funcionalidad de exportación JSON en la app iOS:

```swift
// AppPenia/Services/DataExporter.swift
import SwiftData
import Foundation

struct ExportData: Codable {
    let exportDate: Date
    let users: [UserExport]
    let events: [EventExport]
    let attendances: [AttendanceExport]
    let expenses: [ExpenseExport]
    let payments: [PaymentExport]
}

struct UserExport: Codable {
    let id: String
    let name: String
    let createdAt: Date
    let birthday: Date?
    let hasSede: Bool
    let address: String
    let photoBase64: String?  // Foto como base64
}

struct EventExport: Codable {
    let id: String
    let date: Date
    let notes: String
    let hostId: String?
    let cookId: String?
    let dishwasherId: String?
    let photoBase64: String?
}

struct AttendanceExport: Codable {
    let id: String
    let userId: String
    let eventId: String
    let createdAt: Date
}

struct ExpenseExport: Codable {
    let id: String
    let eventId: String
    let totalAmount: String  // Decimal como string
    let createdAt: Date
}

struct PaymentExport: Codable {
    let id: String
    let expenseId: String
    let userId: String
    let amount: String  // Decimal como string
    let createdAt: Date
}

func exportAllData(modelContext: ModelContext) -> Data? {
    // Fetch all data and convert to export format
    // Return JSON data
}
```

### 11.2 Paso 2: Script de migración en Python

```python
# backend/scripts/migrate_ios_data.py
import json
import asyncio
import base64
from datetime import datetime
from decimal import Decimal
from pathlib import Path
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import async_session_maker
from app.models import Group, Member, Event, Attendance, Expense, Payment
from app.services.storage import upload_photo_from_base64

async def migrate_ios_data(
    export_file: Path,
    group_name: str = "Grupo Migrado",
    admin_account_id: str = None
):
    """
    Migra datos exportados de iOS a la base de datos web.

    Args:
        export_file: Ruta al archivo JSON exportado
        group_name: Nombre del grupo a crear
        admin_account_id: ID del account que será admin del grupo
    """
    with open(export_file, 'r') as f:
        data = json.load(f)

    async with async_session_maker() as db:
        # 1. Crear grupo
        group = Group(
            name=group_name,
            description=f"Migrado desde iOS el {datetime.now().strftime('%Y-%m-%d')}",
            created_by_id=admin_account_id
        )
        db.add(group)
        await db.flush()

        # Mapeo de IDs iOS -> IDs Web
        user_id_map: dict[str, str] = {}
        event_id_map: dict[str, str] = {}
        expense_id_map: dict[str, str] = {}

        # 2. Migrar usuarios -> members
        print(f"Migrando {len(data['users'])} usuarios...")
        for ios_user in data['users']:
            # Subir foto si existe
            photo_url = None
            if ios_user.get('photoBase64'):
                photo_url = await upload_photo_from_base64(
                    ios_user['photoBase64'],
                    f"members/{ios_user['id']}"
                )

            member = Member(
                group_id=group.id,
                name=ios_user['name'],
                birthday=parse_date(ios_user.get('birthday')),
                has_sede=ios_user.get('hasSede', False),
                address=ios_user.get('address', ''),
                photo_url=photo_url,
                created_at=parse_date(ios_user['createdAt'])
            )
            db.add(member)
            await db.flush()
            user_id_map[ios_user['id']] = member.id

        # 3. Migrar eventos
        print(f"Migrando {len(data['events'])} eventos...")
        for ios_event in data['events']:
            photo_url = None
            if ios_event.get('photoBase64'):
                photo_url = await upload_photo_from_base64(
                    ios_event['photoBase64'],
                    f"events/{ios_event['id']}"
                )

            event = Event(
                group_id=group.id,
                date=parse_date(ios_event['date']),
                notes=ios_event.get('notes', ''),
                host_id=user_id_map.get(ios_event.get('hostId')),
                cook_id=user_id_map.get(ios_event.get('cookId')),
                dishwasher_id=user_id_map.get(ios_event.get('dishwasherId')),
                photo_url=photo_url,
                created_at=parse_date(ios_event['createdAt']) if 'createdAt' in ios_event else None
            )
            db.add(event)
            await db.flush()
            event_id_map[ios_event['id']] = event.id

        # 4. Migrar asistencias
        print(f"Migrando {len(data['attendances'])} asistencias...")
        for ios_att in data['attendances']:
            member_id = user_id_map.get(ios_att['userId'])
            event_id = event_id_map.get(ios_att['eventId'])

            if member_id and event_id:
                attendance = Attendance(
                    member_id=member_id,
                    event_id=event_id,
                    created_at=parse_date(ios_att['createdAt'])
                )
                db.add(attendance)

        # 5. Migrar gastos
        print(f"Migrando {len(data['expenses'])} gastos...")
        for ios_expense in data['expenses']:
            event_id = event_id_map.get(ios_expense['eventId'])

            if event_id:
                expense = Expense(
                    event_id=event_id,
                    total_amount=Decimal(ios_expense['totalAmount']),
                    created_at=parse_date(ios_expense['createdAt'])
                )
                db.add(expense)
                await db.flush()
                expense_id_map[ios_expense['id']] = expense.id

        # 6. Migrar pagos
        print(f"Migrando {len(data['payments'])} pagos...")
        for ios_payment in data['payments']:
            expense_id = expense_id_map.get(ios_payment['expenseId'])
            member_id = user_id_map.get(ios_payment['userId'])

            if expense_id and member_id:
                payment = Payment(
                    expense_id=expense_id,
                    member_id=member_id,
                    amount=Decimal(ios_payment['amount']),
                    created_at=parse_date(ios_payment['createdAt'])
                )
                db.add(payment)

        await db.commit()

        print(f"""
        ✅ Migración completada:
        - Grupo creado: {group.name} (ID: {group.id})
        - Miembros: {len(user_id_map)}
        - Eventos: {len(event_id_map)}
        - Gastos: {len(expense_id_map)}
        """)

        return {
            'group_id': group.id,
            'members_migrated': len(user_id_map),
            'events_migrated': len(event_id_map),
            'expenses_migrated': len(expense_id_map)
        }

def parse_date(date_str: str | None) -> datetime | None:
    if not date_str:
        return None
    # Parsear formato ISO de Swift
    return datetime.fromisoformat(date_str.replace('Z', '+00:00'))

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('export_file', type=Path)
    parser.add_argument('--group-name', default='Grupo Migrado')
    parser.add_argument('--admin-id', required=True)
    args = parser.parse_args()

    asyncio.run(migrate_ios_data(
        args.export_file,
        args.group_name,
        args.admin_id
    ))
```

### 11.3 Flujo de migración

1. **En iOS**: Agregar botón "Exportar datos" → genera archivo JSON
2. **Compartir**: Enviar archivo JSON por AirDrop/email
3. **En web**: Admin se registra primero → obtiene su account_id
4. **Ejecutar script**: `python migrate_ios_data.py export.json --admin-id xxx`
5. **Verificar**: Admin revisa datos migrados en la web

---

## 12. Costos Estimados (Tier Gratuito)

| Servicio | Tier Gratuito | Límites |
|----------|---------------|---------|
| Vercel (Frontend) | Hobby | 100GB bandwidth/mes |
| Railway (Backend) | Starter | $5 crédito/mes, ~500 horas |
| Supabase (DB + Storage) | Free | 500MB DB, 1GB storage |
| Mapbox | Free | 50,000 cargas mapa/mes |

**Nota**: Suficiente para grupos pequeños (~50 usuarios activos).

**Alternativa económica para backend**: Render Free Tier (spin down después de 15 min inactividad) o Fly.io Free Tier.

---

## 13. Próximos Pasos para Crear el Proyecto

Este documento está diseñado para ser usado como referencia al crear un nuevo proyecto web. Los pasos para comenzar son:

1. **Crear repositorio nuevo** `apppenia-web/`
2. **Inicializar backend Python**:
   ```bash
   cd apppenia-web
   mkdir backend && cd backend
   python -m venv venv
   pip install fastapi uvicorn sqlalchemy alembic authlib python-jose
   ```
3. **Inicializar frontend React**:
   ```bash
   cd apppenia-web
   npm create vite@latest frontend -- --template react-ts
   cd frontend && npm install
   ```
4. **Configurar servicios externos**:
   - Crear proyecto en Supabase
   - Crear app OAuth en Google Cloud Console
   - Crear app OAuth en Apple Developer
   - Crear cuenta en Mapbox
5. **Ejecutar migraciones de base de datos**
6. **Implementar fase por fase** según la sección 8

---

## 14. Archivos Críticos del Proyecto iOS para Referencia

| Archivo | Contenido |
|---------|-----------|
| `/Users/manoloacademia/Documents/Swift/AppPenia/AppPenia/Models/Expense.swift` | Algoritmo de deudas (líneas 63-138) |
| `/Users/manoloacademia/Documents/Swift/AppPenia/AppPenia/Models/User.swift` | Modelo de usuario |
| `/Users/manoloacademia/Documents/Swift/AppPenia/AppPenia/Models/Event.swift` | Modelo de evento con roles |
| `/Users/manoloacademia/Documents/Swift/AppPenia/AppPenia/Components/SedeMapView.swift` | Lógica de geocodificación |
| `/Users/manoloacademia/Documents/Swift/AppPenia/AppPenia/Views/StatisticsView.swift` | 4 tipos de gráficos |

---

**Documento generado el 2025-12-11**
**Proyecto original**: AppPenia iOS (SwiftUI + SwiftData)
**Destino**: Aplicación Web (Python FastAPI + React + Supabase)
