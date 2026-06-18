# Interface

An **interface** is everything a caller must know to use a module correctly.

It includes type signatures, methods, data shapes, invariants, ordering constraints, error modes, configuration, performance expectations, and lifecycle rules.

## Accepted when

- Callers can use the module without reading the implementation.
- Required invariants and ordering rules are explicit at the interface.
- Error modes are part of the caller contract.
- External representations are translated before they become caller knowledge.
- The interface is smaller or clearer than the behavior it unlocks.
- Tests can verify behavior through the same surface callers use.

## Evidence to show

- Caller-facing functions/types/messages.
- Required invariants and ordering rules.
- Error/result contract.
- External representations translated at the edge.
- Example caller code using only the interface.
- Tests that exercise behavior through this interface.
