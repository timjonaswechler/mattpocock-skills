# Module

A **module** is a named unit with an **interface** and an **implementation**. It can be a function, class, package, feature slice, or runtime subsystem.

A module is worth naming when it concentrates a responsibility that callers benefit from treating as one thing.

## Accepted when

- The module has a clear caller-facing interface.
- The implementation hides meaningful decisions behind that interface.
- Callers can describe what the module provides without knowing its internal steps.
- The module name matches project domain vocabulary where domain behavior is involved.
- Deleting the module would push meaningful complexity back into multiple callers.
- Tests can target the module through its interface.

## Evidence to show

- Module name and responsibility.
- Caller list.
- Interface shape.
- Behavior and decisions hidden inside.
- Test surface.
- Deletion-test result: what complexity would move to callers if the module disappeared.
