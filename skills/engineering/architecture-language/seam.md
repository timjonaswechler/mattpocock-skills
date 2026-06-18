# Seam

A **seam** is the place where behavior can vary without changing callers. It is where a module's interface lives.

A seam is a design claim about dependency direction, caller knowledge, and testability.

## Accepted when

- Callers depend on the module interface rather than the implementation.
- Behavior can vary behind the seam without caller changes.
- The inner module uses domain-owned concepts and types.
- External DTOs, SDK types, database records, UI state, transport payloads, or framework details are translated at the edge.
- Existing direct dependency paths have migrated to the seam.
- Tests exercise behavior through the public interface at this seam.
- The dependency category has an appropriate strategy from [dependency categories](dependency-categories.md).

## Evidence to show

- The interface that forms the seam.
- Current and intended callers.
- What behavior varies behind the seam.
- Adapter or dependency strategy.
- Translation points at the edge.
- Import/dependency direction that demonstrates callers cross the seam.
- Tests that verify behavior through the seam.
