TimelockVault-X

A simple and secure Clarity smart contract for locking STX tokens until a specified future time. Designed for decentralized escrow, delayed payouts, and time-based savings on the [Stacks blockchain](https://www.stacks.co/).

---

 Overview

**TimelockVault-X** allows users to deposit STX into the contract with a specific unlock time (as a UNIX timestamp). Once locked, the tokens cannot be withdrawn until the unlock time has passed, ensuring predictable, trustless fund management.

---
 Features

- Time-Locked STX Deposits** — Lock STX for a future timestamp.
- User-Scoped Vaults** — Each user manages their own time-locks.
- Enforced Unlock Time** — Funds are non-retrievable until the lock period expires.
- On-chain Events** — Emits deposit and withdrawal events for transparency.

---

 Functions

| Function | Description |
|---------|-------------|
| `lock-stx (unlock-time uint)` | Lock STX until the specified `unlock-time`. |
| `withdraw ()` | Withdraw your STX after the time lock expires. |
| `get-user-lock (user principal)` | View lock status for a specific user. |

---
