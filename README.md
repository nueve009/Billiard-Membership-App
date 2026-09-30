# RackUp

> A mobile app that helps billiard halls manage memberships, table timers, and billing.
> *(RackUp is a placeholder name. Rename it anytime.)*

## Description

RackUp is a membership and table-time tracker for billiard halls. It runs on phones and tablets.

- **Members** can see how many hours or how much credit they have left.
- **Staff** can see which tables are free, in use, or reserved, and start or stop a table timer with one tap.
- The app works out the bill automatically, so nobody has to watch the clock.
- Everyone sees the same data, because it is stored in one shared online database.

## Why This Exists

This is a personal learning project. It has two goals:

1. **Practice real-world programming skills**: online databases, login and roles, access rules, time and money math, and screens that work on both phones and tablets.
2. **Solve a real problem**: in many billiard halls, remaining time is tracked by hand. Players sometimes get told their time is up while they still have time left, and staff must keep checking the clock. One shared, accurate timer fixes both problems.

The project is built as if it will be deployed for a real hall.

## Tech Stack

> These are proposed choices. Change them if you prefer something else.

| Part | Choice | Why |
|---|---|---|
| App framework | React Native with Expo | One codebase for Android and iOS, phones and tablets |
| Language | TypeScript | Catches many mistakes before the app runs |
| Database | Supabase (PostgreSQL) | One shared database for all devices, like a real deployed app |
| Login and roles | Supabase Auth | Sign up, log in, member vs staff |
| Access rules | Row Level Security (RLS) | Members see only their own data, staff see everything |
| Live updates | Supabase Realtime | Table grid updates when another device changes a table |
| Navigation | Expo Router or React Navigation | Moving between screens |
| Testing | Jest | Test the billing and timer logic |

**Later (bonus):** SQLite on the device as an offline cache, so the app still opens when the signal is weak.

## Proposed Project Structure

```
rackup/
├── README.md
├── package.json
├── .env                  # Supabase URL and public key (never commit secrets)
├── app/                  # Screens (what the user sees)
│   ├── (auth)/
│   │   └── login.tsx     # Login and sign up
│   ├── (staff)/
│   │   ├── tables.tsx    # Table grid: free / in use / reserved
│   │   └── members.tsx   # Member list and search
│   └── (member)/
│       └── card.tsx      # Membership card and remaining time
├── components/           # Reusable pieces (TableCard, Timer, Button)
├── lib/
│   └── supabase.ts       # Connects the app to Supabase
├── db/                   # Functions that read and write data
│   ├── members.ts
│   ├── tables.ts
│   └── sessions.ts
├── logic/                # Rules of the app, no screens here
│   ├── billing.ts        # Time played x rate = cost
│   └── timer.ts          # Elapsed time from start time
├── supabase/             # Database setup
│   ├── migrations/       # Table definitions (SQL files)
│   └── policies.sql      # Row Level Security rules
├── types/                # Shared TypeScript types
└── tests/                # Tests for logic/
```

Keeping `logic/` separate from `app/` means the important rules (billing, timers) are easy to test and easy to change.

## Core Concepts

**Member**
A person with a membership. Has a name, contact info, and hours or credit left.

**Table**
A billiard table in the hall. Has a number, a type (pool, snooker, carom), an hourly rate, and a status: `free`, `in_use`, or `reserved`.

**Session**
One period of play on a table. Stores the table, the member, the **start time**, the **end time**, and the final cost.

**Remaining time**
`hours bought - hours used`. This is the number that removes the "is my time really up?" arguments.

**Roles**
Two kinds of users: `member` and `staff`. Members can see only their own hours and history. Staff can manage tables, members, and sessions.

**Row Level Security (RLS)**
Rules inside the database that decide who can read or change which rows. Without them, anyone with the app could read everyone's data.

**Timer (important)**
Do not add one every second. Save the start time, then calculate `now - start time`. Use the **server's time** (`now()` in the database), not the phone's clock, so all devices agree.

**Billing**
`time played x hourly rate`, minus any credit the member has.

## Roadmap

**Version 1 (foundation)**
- [ ] Set up Supabase project and connect the app
- [ ] Login and roles (member vs staff)
- [ ] Row Level Security rules
- [ ] Members: add, edit, list
- [ ] Tables: add, edit, list, status
- [ ] Start and stop a table timer
- [ ] Calculate the bill and update remaining time

**Version 2 and beyond**
- [ ] Bookings (with a database rule that blocks overlapping times)
- [ ] Live table grid using Realtime
- [ ] QR code check-in
- [ ] Dashboard (revenue, busy hours)
- [ ] Offline cache with SQLite
- [ ] Scorekeeper (start with 8-ball)
- [ ] Tournament schedules

## Getting Started

> Fill this in once the repo is created.

### Requirements
- Node.js (version: _TBD_)
- A free [Supabase](https://supabase.com) account and project
- Expo Go app on your phone, or an Android/iOS emulator

### Setup
```bash
# 1. Clone the repo
git clone <your-repo-url>
cd rackup

# 2. Install packages
npm install

# 3. Add your Supabase details
cp .env.example .env
# then open .env and fill in your project URL and public (anon) key

# 4. Start the app
npx expo start
```

> **Safety note:** only the public (anon) key goes in the app. Never put the secret `service_role` key in the app or commit it to GitHub.

### Running tests
```bash
npm test
```

## License

_TBD_
