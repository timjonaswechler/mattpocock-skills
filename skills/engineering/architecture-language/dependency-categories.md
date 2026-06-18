# Dependency Categories

Dependency shape determines the right seam and test strategy.

## In-process

Pure computation or in-memory state with no I/O.

Accepted strategy:

- Keep the seam at the module interface.
- Test through the module interface with real implementation code.
- Use internal helpers freely inside the implementation.

## Local-substitutable

Dependencies with local stand-ins, such as a test database, in-memory filesystem, fake clock, local broker, or PGLite-style replacement.

Accepted strategy:

- Keep the external seam small and domain-owned.
- Use the local stand-in in tests.
- Keep stand-in setup behind test helpers that match the module interface.

## Remote but owned

Your own services across HTTP, gRPC, queues, jobs, or other network/process seams.

Accepted strategy:

- Define a port/interface at the seam.
- Put domain logic in the module behind the seam.
- Provide a production transport adapter.
- Provide a local/test adapter that satisfies the same interface.
- Test module behavior through the port with the local/test adapter.

## True external

Third-party systems such as payment providers, email providers, hosted APIs, or vendor SDKs.

Accepted strategy:

- Define a domain-owned interface at the seam.
- Translate vendor representations at the adapter edge.
- Keep vendor error shapes out of the inner module.
- Test module behavior through a mock/fake adapter that satisfies the domain-owned interface.
- Use contract/smoke tests where useful to verify the production adapter against the vendor.
