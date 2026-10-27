# Design notes

## Purpose

This repository is a deterministic software model for exploring a few interlocking constraints in Ada. It has no real-time guarantees, external inputs, outputs, or operational role. Terminology is inspired by railway practice, while all layout details and simplifications here are invented for this example.

## Components

`Interlocking` owns all mutable simulated state. Callers can update abstract sensor inputs, request or cancel a route, request point movement, query a signal aspect, and obtain a read-only snapshot. `Simulator` is a minimal console client. `Test_Runner` exercises the public API and fails immediately when an expected result changes.

Keeping state in one package makes the toy's rules easy to follow. It is not a recommendation for production architecture, concurrency, or safety partitioning.

## Invariants exercised by this model

1. An unset, failed, locked-for-cancellation, or otherwise invalid route presents Stop.
2. A route can be set only when every modelled section is explicitly Clear, the point has the required detected position, no point fault is active, and the opposing route is Available.
3. A set route locks the point against movement and excludes the other route.
4. Occupied or Unknown approach detection prevents route cancellation. The simplified `Approach_Locked` state retains the point lock until the approach and all modelled route sections are explicitly clear.
5. Unknown section detection never counts as clear.

`Failed` exists in the route-state type as a possible extension point; this version does not transition into it. Cancellation is not a simulated train passage. The route can be released only after all sections are clear, which is intentionally conservative but far too crude to represent a real release sequence.

## State transitions

```text
Available --valid request--> Set --cancel, all clear--> Available
                              |
                              +--cancel, approach occupied--> Approach_Locked
Approach_Locked --cancel, all clear--> Available
```

An approach-locked route indicates the signal is at Stop while locking remains. If route sections become occupied, cancellation remains rejected. No timer or automatic release is implemented; this avoids suggesting that a made-up delay is safe.

## Assumptions and limitations

- Fixed layout, fixed enumerations, one point, two mutually exclusive routes.
- All four sections are checked for both routes; no actual topology is encoded.
- Point movement is instantaneous and conflates a command with a detected position.
- Section and point values arrive as trusted calls; there is no sensor integrity or stale-data handling.
- No concurrency, persistence, event log, operator interface, communications, train dynamics, braking model, signal sighting, flank protection, route overlap design, or jurisdiction-specific operating rules.
- Assertions and tests are not a safety case. No hazard analysis, independent verification, tool qualification, SIL claim, certification, or deployment review is supplied.

Any extension should preserve fail-closed handling and make assumptions executable or explicit. The code is deliberately not connected to real railway hardware.
