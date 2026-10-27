# Fault scenarios

These are software-level examples for exercising the prototype, not a complete railway hazard analysis.

| Scenario | Model input | Expected response |
|---|---|---|
| Train occupies a section | Set any section to `Occupied`, then request route | Request rejected; signal remains Stop |
| Detection is unavailable or contradictory | Set any section to `Unknown` | Request rejected as unknown; Unknown never counts as Clear |
| Points are not in the requested position | Leave point Normal and request diverging route | Request rejected; no route lock is acquired |
| Point mechanism failure | Set point failure true, then request a route | Request rejected; signal stays Stop |
| Point failure after route is set | Set failure true while route is Set | Signal aspect returns Stop; route and point lock remain until safe cancellation |
| Conflicting route demand | Set main route, then request diverging route | Second request rejected; first route retains point lock |
| Cancellation while train approaches | Mark approach Occupied and cancel set route | Signal goes to Stop; route becomes `Approach_Locked`; point remains locked |
| Unknown approach on cancellation | Mark approach Unknown and cancel | Cancellation rejected; existing locking remains |
| Section occupied during release | Keep any route section Occupied and cancel | Cancellation rejected; locks remain |

## Deliberate omissions

The prototype does not simulate intermittent faults, common-cause failures, timing, wrong-side sensor failures, communication loss, point detection disagreement, train overrun, route proving races, or safety-rated redundancy. The `Set_Section` and `Set_Point_Failure` procedures are trusted test controls. Real failure analysis must be specific to the actual infrastructure, equipment, operating rules, and applicable standards.
