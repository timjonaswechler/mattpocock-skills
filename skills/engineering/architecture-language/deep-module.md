# Deep Module

A **deep module** gives callers a lot of behavior behind a small, clear interface.

Depth is measured by caller leverage: how much useful behavior callers get per unit of interface they must learn.

## Accepted when

- Callers have less to know than before.
- Meaningful complexity moved behind the interface.
- The interface is smaller or clearer than the implementation complexity it hides.
- The module provides leverage across multiple callers, workflows, or tests.
- The deletion test shows the module earns its keep: removing it would push complexity back into callers.
- Tests verify behavior through the module interface rather than internal steps.
- Internal seams, helpers, and submodules stay private to the implementation unless callers need them.

## Evidence to show

- Before/after caller knowledge: what callers had to know before vs. after.
- Interface shape and examples.
- Complexity hidden behind the interface.
- Caller/test leverage gained.
- Deletion-test result.
- Tests that exercise the deep module through its interface.
