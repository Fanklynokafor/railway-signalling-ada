# Railway Signalling Ada

A small, deterministic railway interlocking simulation written entirely in Ada. It models a miniature layout with four detection sections, one shared point, and two mutually exclusive routes. The project is intended to make basic interlocking ideas tangible and to provide a base for learning about state, constraints, and fault handling.

> **Safety boundary:** This is a simulation prototype for education and experimentation. It is not certified, safety-assured, or suitable for operational use. Do not connect it to railway equipment, use it to authorize train movements, or treat its output as signalling advice.

## Build and run

The project targets Ada 2022 and GNAT. With Alire installed:

```sh
alr build
alr run
```

Run the checks with the GNAT project builder:

```sh
gprbuild -P railway_signalling.gpr test_runner.adb
./bin/test_runner
```

Or compile directly with GNAT Make where Alire is unavailable:

```sh
mkdir -p bin obj
gnatmake -gnat2022 -gnata -Isrc -D obj -o bin/test_runner tests/test_runner.adb
gnatmake -gnat2022 -gnata -Isrc -D obj -o bin/simulator src/simulator.adb
./bin/test_runner
./bin/simulator
```

No third-party Ada libraries are used. Alire configuration is included so the package can be managed in a conventional Ada workflow.

## What the model demonstrates

- Signals default to **Stop** and show **Proceed** only for a set route whose required point position is detected, whose point has not failed, and whose modelled sections are all clear.
- Unknown train detection blocks route setting and cancellation; it is treated as unsafe information.
- Routes exclude one another because both use a shared point and corridor in this deliberately compact layout.
- A set route locks the point. A new point fault forces the signal to Stop while retaining the route lock.
- Cancelling with an occupied approach applies a simplified approach lock: the signal goes to Stop, the route remains locked, and the model requires the approach to clear before cancellation succeeds.
- Results are explicit enumerated values, making rejection reasons visible to the caller.

## Layout and assumptions

`Approach`, `Junction`, `Platform`, and `Overlap` are abstract detection sections. Both routes conservatively check every section because this prototype represents one shared corridor, not surveyed route geometry. The main route requires the point to be `Normal`; the diverging route requires `Reverse`. Route requests do not move points automatically: the simulator requires the correct detected position first.

For ease of demonstration, `Move_Point` instantaneously changes the modeled detection value. That is a major abstraction: a real system must separate the command to move a point from independent proof that it is correctly positioned and locked. The model also treats a boolean point-failure input and section state as idealized inputs. It has no field interfaces, train identity, timing, signal aspects beyond Stop/Proceed, braking curves, overlaps calculated from standards, communications, human operating rules, safety case, or hardware redundancy.

Future me: keep this boundary conspicuous if the model grows. A more detailed simulation should represent command, movement, detection, and locking as separate states, then add time and fault injection without turning this toy into an implied control system.

## Project map

- `src/interlocking.ads` and `src/interlocking.adb`: typed model and interlocking rules.
- `src/simulator.adb`: short demonstration run.
- `tests/test_runner.adb`: executable unit-style checks for normal and fault paths.
- `DESIGN.md`: architecture, invariants, and engineering limits.
- `FAULT_SCENARIOS.md`: manually readable fault catalogue and expected safe responses.

## References

The model borrows only high-level concepts; it is not an implementation of any referenced standard.

- [Network Rail: Signals explained](https://www.networkrail.co.uk/stories/signals-explained/) — overview of signals, train position detection, points, and the principle that faults commonly result in restrictive signals.
- [RSSB: Switches and Crossings, RIS-7707-INS](https://consultations.rssb.co.uk/_entity/sharepointdocumentlocation/e755957b-950b-ee11-8f6e-000d3aba3cb5/2ab10dab-d681-4911-b881-cc99413f07b6?file=07.+RIS-7707-INS.pdf) — definitions of interlocking, point detection, and facing point locks.
- [RSSB: Signalling Layout and Signal Aspect Sequence Requirements, RIS-0703-CCS](https://consultations.rssb.co.uk/_entity/sharepointdocumentlocation/f08b9dfa-b2fb-ec11-82e5-000d3ade338f/2ab10dab-d681-4911-b881-cc99413f07b6?file=05.+RIS_0703_CCS.pdf) — informative background on approach locking and maintaining route integrity after cancellation.
- [European Union Agency for Railways: ERTMS](https://www.era.europa.eu/domains/infrastructure/european-rail-traffic-management-system-ertms_en) — overview of the broader European train control and signalling system.

Standards and rules change and are jurisdiction-specific. Consult the current applicable standards and competent railway safety engineers for any real project.
