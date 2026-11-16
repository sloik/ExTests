# Formal model (TLA+)

`ExTestsLaws.tla` is a finite TLA+ model of `Sources/ExTests`, the fluent `XCTestExpectation`
helpers `strict / soft / expect(_:) / once / onceStrict / inverted / regular`.

**Abstraction.** An expectation is the record `[n, strict, inv]` =
`(expectedFulfillmentCount, assertForOverFulfill, isInverted)`; `n in 1..3`, fulfil count `k in 0..4`.
Each helper is a pure record update (the Swift helpers mutate and return `self`; for a fluent chain on a
single object this is equivalent). `Passes(e, k)` encodes the *documented XCTest outcome* of fulfilling an
expectation `k` times: inverted passes iff `k = 0`; otherwise `k >= n`, and also `k <= n` when
over-fulfilment asserts. That predicate is XCTest's rule, assumed from Apple's documentation, not code in this
repo, so those invariants check the helpers' configuration against that assumed rule.

| Invariant | Swift API it abstracts |
|---|---|
| `TypeOK` | well-formed expectation |
| `OnceIsExpectOne` | `once()` == `expect(1)` |
| `OnceStrictIsOnceThenStrict`, `OnceStrictIsExactlyOnce` | `onceStrict()` == `expect(1).strict()`; passes only for exactly one fulfil |
| `ExpectSetsCountOnly` | `expect(_:)` touches only `expectedFulfillmentCount` |
| `StrictSoftLastWins`, `InvertedRegularLastWins` | `strict/soft`, `inverted/regular` override each other |
| `Idempotent`, `FieldsIndependent` | helpers are idempotent and commute across different fields |
| `SoftIsLenient`, `StrictIsExact`, `SoftWeakerThanStrict` | over-fulfil allowed after `soft()`, rejected after `strict()` |
| `InvertedPassesOnlyUnfulfilled`, `RegularNeedsFulfilment` | `inverted()` / `regular()` |

## Non-vacuity

Mutants: `once_strict_forgets_strict` (caught by `OnceStrictIsExactlyOnce`), `soft_noop`
(`SoftIsLenient`), `regular_noop` (`InvertedRegularLastWins`). `run_tlc.sh` fails if a mutant passes.

## Running

Local runs and CI use the shared Oracle queue through `formal/run_tlc.sh`.
They require an installed, authorized `tla-queue` client and configured access to
the maintainer-operated Oracle backend. Ask the maintainer for client setup and
access; public repository access does not provide queue access.

Run from the repository root after that setup:

```sh
TLA_JAR=/path/to/tla2tools-1.7.4.jar formal/run_tlc.sh   # needs Java 11+ on Oracle
```

`TLA_JAR` and optional `JAVA` overrides refer to **Oracle-side tools**. The example
JAR path must already exist on Oracle; leave the overrides unset to use the remote
defaults. For this check, do not run Java/TLC locally, install or download a local
toolchain (including with `mise`), or use direct SSH as a fallback. A missing
client, unavailable queue, incomplete run, or nonzero wrapper exit is not a
verification pass.

CI: `.github/workflows/oracle-tla.yml` (self-hosted Oracle ARM64 runner, default branch / manual dispatch).

## Limits

Not modelled: `wait(for:)`, timeouts, threads, `XCTWaiter` results, `expectation description`.
The XCTest outcome rule is an assumption (see above); the model does not prove conformance of the Swift code.
Defaults of a fresh `XCTestExpectation` are not asserted: `Init` ranges over all configurations.
