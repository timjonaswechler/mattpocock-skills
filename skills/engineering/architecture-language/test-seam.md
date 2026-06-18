# Test Seam

A **test seam** is the public interface through which behavior is verified.

A good test seam exercises the behavior pattern as callers experience it. The same seam should be meaningful to both tests and production callers.

## Accepted when

- The test exercises the real behavior pattern at the caller-facing interface.
- The test observes outcomes through the public interface.
- The setup uses real code behind the seam wherever practical.
- Required test adapters represent real dependency variation from [dependency categories](dependency-categories.md).
- The test would survive internal refactors that preserve behavior.
- The test name describes behavior in project domain vocabulary.
- The test gives a fast, deterministic signal for the behavior it protects.

## Evidence to show

- Behavior being protected.
- Interface crossed by the test.
- Production caller pattern represented by the test.
- Adapter or stand-in strategy for external dependencies.
- Observable outcome asserted by the test.
- Why this seam gives confidence for the behavior.
