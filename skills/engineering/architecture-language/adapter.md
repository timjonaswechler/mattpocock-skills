# Adapter

An **adapter** is a concrete implementation of an interface at a seam. It translates between the outside world and the module's domain-owned interface.

Adapter describes a role at a seam. The adapter may be small or large internally, but its job is to satisfy the seam's interface.

## Accepted when

- The adapter satisfies a named interface at a seam.
- It translates external representations into domain-owned types and concepts.
- It handles integration mechanics such as I/O, transport, persistence, serialization, and error mapping.
- Domain decisions live in the module behind the seam; the adapter supplies external facts in the module's language.
- The adapter can be replaced by another adapter when the dependency category calls for variation.
- Tests use the seam's interface and the appropriate adapter strategy from [dependency categories](dependency-categories.md).

## Evidence to show

- Interface the adapter satisfies.
- External system or representation it adapts.
- Translation map: external shape → domain-owned shape.
- Error mapping strategy.
- Adapter family when claiming a proven seam, e.g. production adapter + local/test adapter.
- Tests that cross the seam through the interface.
