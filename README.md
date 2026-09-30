# RackUp

> A mobile app that helps billiard halls manage memberships, table timers, and billing.
> *(RackUp is a placeholder name. Rename it anytime.)*

## Description

RackUp is a membership and table-time tracker for billiard halls. It runs on phones and tablets.

- **Members** can see how many hours or how much credit they have left.
- **Staff** can see which tables are free, in use, or reserved, and start or stop a table timer with one tap.
- The app works out the bill automatically, so nobody has to watch the clock.

## Why This Exists

This is a personal learning project. It has two goals:

1. **Practice real-world programming skills**: databases, login, time and money math, and screens that work on both phones and tablets.
2. **Solve a real problem**: in many billiard halls, remaining time is tracked by hand. Players sometimes get told their time is up while they still have time left, and staff must keep checking the clock. One shared, accurate timer fixes both problems.

## Tech Stack

> These are proposed choices. Change them if you prefer something else.

| Part | Choice | Why |
|---|---|---|
| App framework | React Native with Expo | One codebase for Android and iOS, phones and tablets |
| Language | TypeScript | Catches many mistakes before the app runs |
| Local database | SQLite (via `expo-sqlite`) | Simple, works offline, good for version 1 |
| Navigation | Expo Router or React Navigation | Moving between screens |
| Testing | Jest | Test the billing and timer logic |

**Later (version 2+):** a cloud backend (for example Supabase or Firebase) so members and staff can use different devices with the same data.

## Proposed Project Structure

```
rackup/
├── README.md
├── package.json
├── app/                  # Screens (what the user sees)
│   ├── (staff)/
│   │   ├── tables.tsx    # Table grid: free / in use / reserved
│   │   └── members.tsx   # Member list and search
│   └── (member)/
│       └── card.tsx      # Membership card and remaining time
├── components/           # Reusable pieces (TableCard, Timer, Button)
├── db/                   # Database setup and queries
│   ├── schema.ts         # Table definitions
│   └── queries.ts        # Add, read, update data
├── logic/                # Rules of the app, no screens here
│   ├── billing.ts        # Time played x rate = cost
│   └── timer.ts          # Elapsed time from start time
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

**Timer (important)**
Do not add one every second. Save the start time, then calculate `now - start time`. This keeps the timer correct even if the app is closed or the tablet goes to sleep.

**Billing**
`time played x hourly rate`, minus any credit the member has.

## Roadmap

**Version 1 (foundation)**
- [ ] Members: add, edit, list
- [ ] Tables: add, edit, list, status
- [ ] Start and stop a table timer
- [ ] Calculate the bill and update remaining time

**Version 2 and beyond**
- [ ] Bookings (with a check that blocks overlapping times)
- [ ] Login and roles (member vs staff)
- [ ] QR code check-in
- [ ] Dashboard (revenue, busy hours)
- [ ] Scorekeeper (start with 8-ball)
- [ ] Tournament schedules

## Getting Started

> Fill this in once the repo is created.

### Requirements
- Node.js (version: _TBD_)
- Expo Go app on your phone, or an Android/iOS emulator

### Setup
```bash
# 1. Clone the repo
git clone <your-repo-url>
cd rackup

# 2. Install packages
npm install

# 3. Start the app
npx expo start
```

### Running tests
```bash
npm test
```

## License

_TBD_
