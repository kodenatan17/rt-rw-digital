# 🏗️ Flutter Architecture Skill (FDD + Clean Architecture)

## 🎯 Purpose

Enforce **Feature-Driven Clean Architecture (FDD)** with:

* strict layer separation
* Single Source of Truth (SSOT)
* scalable and maintainable structure
* minimal over-engineering

---

## 🏗️ Architecture Pattern (MANDATORY)

Use **Feature-Driven Structure**:

```
feature/<feature_name>/
 ├── application/
 │    ├── entities/
 │    ├── repositories/      # abstract
 │    └── usecases/
 │
 ├── infrastructure/
 │    ├── models/
 │    ├── datasources/
 │    └── repositories/      # implementation
 │
 └── presentation/
      ├── bloc/
      ├── pages/
      └── widgets/
```

---

## 🔒 Layer Rules (STRICT)

### 1. Dependency Direction

```
presentation → application → infrastructure
```

Rules:

* presentation MUST NOT access infrastructure
* bloc MUST call usecase (if exists)
* usecase MUST depend on repository abstraction
* infrastructure MUST NOT depend on presentation

---

### 2. SSOT (Single Source of Truth)

* state MUST exist ONLY in Bloc
* UI MUST be stateless
* NO duplicated state across layers

❗ Violation = FAIL

---

### 3. Bloc Rules

* handle state only
* no API / SDK calls
* minimal business logic
* no direct repository implementation access

---

### 4. UseCase Rules

* one responsibility per usecase
* REQUIRED only if logic is non-trivial

Allowed:

* simple CRUD can skip or merge usecase

---

### 5. Repository Rules

* abstraction in `application/repositories`
* implementation in `infrastructure/repositories`
* no direct API usage outside datasource

---

### 6. Data Source Rules

* all API / SDK / external calls live here
* no business logic

---

## ⚡ Mode Selection (IMPORTANT)

### 🔹 SIMPLE MODE (CRUD)

If feature is simple:

* UseCase is OPTIONAL
* Bloc can directly call repository abstraction

---

### 🔹 STRICT MODE (COMPLEX LOGIC)

If feature contains:

* business logic
* validation rules
* calculations
* workflows

Then:

* UseCase is REQUIRED
* strict layering MUST be followed

---

## 🚫 Forbidden

* UI calling repository directly
* Bloc calling API / SDK
* business logic inside UI
* cross-layer dependency violation
* duplicated state outside Bloc

---

## 🧪 Naming Convention

Feature:

* `warga`, `iuran`, `call`

UseCase:

* `CreateWarga`
* `GetWargaList`

Bloc:

* `WargaBloc`

Event:

* `CreateWargaEvent`

State:

* `WargaState`

---

## 🧠 Enforcement Rule (CRITICAL)

If this skill is injected:

* MUST follow all rules above
* MUST NOT simplify architecture incorrectly
* MUST fix any violation before final output

---

## ⚙️ Optimization Rules

* SIMPLE > PERFECT
* DO NOT over-engineer
* DO NOT add unnecessary abstraction
* prefer minimal layers for simple features

---

## ✅ Goal

* maintainable structure
* clear separation of concerns
* scalable feature modules
* consistent architecture across project
