-------------------------- MODULE ExTestsLaws ---------------------------
(* Finite model of Sources/ExTests: the fluent XCTestExpectation helpers   *)
(* strict / soft / expect(n) / once / onceStrict / inverted / regular.      *)
(* An expectation is the record [n, strict, inv] = (expectedFulfillmentCount, *)
(* assertForOverFulfill, isInverted). Each helper returns self after        *)
(* mutating one field (the class is a reference type; modelled as a pure    *)
(* record update, which is equivalent for a fluent chain on one object).    *)
(* Passes(e, k) abstracts the DOCUMENTED XCTest outcome of fulfilling the   *)
(* expectation k times; it is XCTest's rule, not code in this repo.         *)
EXTENDS Naturals

CONSTANTS MaxN,     \* largest expectedFulfillmentCount modelled
          MaxK,     \* largest number of fulfill() calls modelled
          Mutant

Exps == [n : 1..MaxN, strict : BOOLEAN, inv : BOOLEAN]
Ks   == 0..MaxK

\* ExTests.swift
Strict(e)  == [e EXCEPT !.strict = TRUE]
Soft(e)    == IF Mutant = "soft_noop" THEN e ELSE [e EXCEPT !.strict = FALSE]
Expect(e, c) == [e EXCEPT !.n = c]
Once(e)    == Expect(e, 1)
OnceStrict(e) ==
  IF Mutant = "once_strict_forgets_strict" THEN Once(e) ELSE Strict(Once(e))
Inverted(e) == [e EXCEPT !.inv = TRUE]
Regular(e)  == IF Mutant = "regular_noop" THEN e ELSE [e EXCEPT !.inv = FALSE]

\* Documented XCTest outcome for k fulfill() calls.
Passes(e, k) ==
  IF e.inv THEN k = 0
  ELSE k >= e.n /\ (~e.strict \/ k <= e.n)

VARIABLE e
Init == e \in Exps
Next == UNCHANGED e
Spec == Init /\ [][Next]_e

TypeOK == e \in Exps
OnceIsExpectOne == Once(e) = Expect(e, 1) /\ Once(e).n = 1
OnceStrictIsOnceThenStrict == OnceStrict(e) = Strict(Once(e)) /\ OnceStrict(e).strict
ExpectSetsCountOnly ==
  \A c \in 1..MaxN : Expect(e, c).n = c /\ Expect(e, c).strict = e.strict /\ Expect(e, c).inv = e.inv
StrictSoftLastWins ==
  Soft(Strict(e)).strict = FALSE /\ Strict(Soft(e)).strict = TRUE
InvertedRegularLastWins ==
  Regular(Inverted(e)).inv = FALSE /\ Inverted(Regular(e)).inv = TRUE
Idempotent ==
  Strict(Strict(e)) = Strict(e) /\ Soft(Soft(e)) = Soft(e)
  /\ Inverted(Inverted(e)) = Inverted(e) /\ Regular(Regular(e)) = Regular(e)
FieldsIndependent ==
  Strict(Inverted(e)) = Inverted(Strict(e)) /\ Soft(Regular(e)) = Regular(Soft(e))
  /\ \A c \in 1..MaxN : Expect(Strict(e), c) = Strict(Expect(e, c))
SoftIsLenient ==
  \A k \in Ks : Passes(Regular(Soft(e)), k) = (k >= e.n)
StrictIsExact ==
  \A k \in Ks : Passes(Regular(Strict(e)), k) = (k >= e.n /\ k <= e.n)
SoftWeakerThanStrict ==
  \A k \in Ks : Passes(Strict(e), k) => Passes(Soft(e), k)
InvertedPassesOnlyUnfulfilled ==
  \A k \in Ks : Passes(Inverted(e), k) = (k = 0)
RegularNeedsFulfilment ==
  \A k \in Ks : Passes(Regular(e), 0) = FALSE
OnceStrictIsExactlyOnce ==
  \A k \in Ks : Passes(Regular(OnceStrict(e)), k) = (k = 1)
=============================================================================
