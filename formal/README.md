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

```sh
TLA_JAR=/path/to/tla2tools-1.7.4.jar formal/run_tlc.sh   # needs Java 11+
```

CI: `.github/workflows/oracle-tla.yml` (self-hosted Oracle ARM64 runner, default branch / manual dispatch).

## Limits

Not modelled: `wait(for:)`, timeouts, threads, `XCTWaiter` results, `expectation description`.
The XCTest outcome rule is an assumption (see above); the model does not prove conformance of the Swift code.
Defaults of a fresh `XCTestExpectation` are not asserted: `Init` ranges over all configurations.
