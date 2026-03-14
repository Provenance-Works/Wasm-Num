import WasmNum

/-!
# Test Helpers

Lightweight test infrastructure: assertion counter, pass/fail reporting.
Every test module uses these helpers.
-/

namespace WasmTest

/-- Test result accumulator -/
structure TestResult where
  passed : Nat := 0
  failed : Nat := 0
  failures : List String := []
deriving Repr

instance : Append TestResult where
  append a b := {
    passed := a.passed + b.passed
    failed := a.failed + b.failed
    failures := a.failures ++ b.failures
  }

def TestResult.empty : TestResult := { passed := 0, failed := 0, failures := [] }

def TestResult.ok (name : String) : TestResult :=
  { passed := 1, failed := 0, failures := [] }

def TestResult.fail (name : String) (msg : String := "") : TestResult :=
  { passed := 0, failed := 1, failures := [s!"{name}: {msg}"] }

/-- Assert equality -/
def assertEqual {α : Type} [BEq α] [ToString α] (name : String) (actual expected : α) : TestResult :=
  if actual == expected then TestResult.ok name
  else TestResult.fail name s!"expected {expected}, got {actual}"

/-- Assert Option is some with expected value -/
def assertSome {α : Type} [BEq α] [ToString α] (name : String) (actual : Option α) (expected : α) : TestResult :=
  match actual with
  | some v =>
    if v == expected then TestResult.ok name
    else TestResult.fail name s!"expected some {expected}, got some {v}"
  | none => TestResult.fail name "expected some, got none"

/-- Assert Option is none -/
def assertNone {α : Type} (name : String) (actual : Option α) : TestResult :=
  match actual with
  | none => TestResult.ok name
  | some _ => TestResult.fail name "expected none, got some"

/-- Assert boolean is true -/
def assertTrue (name : String) (actual : Bool) : TestResult :=
  if actual then TestResult.ok name
  else TestResult.fail name "expected true, got false"

/-- Assert boolean is false -/
def assertFalse (name : String) (actual : Bool) : TestResult :=
  if !actual then TestResult.ok name
  else TestResult.fail name "expected false, got true"

/-- Print test summary -/
def TestResult.summary (suiteName : String) (r : TestResult) : String :=
  let status := if r.failed == 0 then "PASS" else "FAIL"
  let base := s!"[{status}] {suiteName}: {r.passed}/{r.passed + r.failed} tests passed"
  if r.failed == 0 then base
  else
    let failMsgs := r.failures.foldl (fun acc f => acc ++ s!"\n  FAILED: {f}") ""
    base ++ failMsgs

/-- Helper for creating a 1-page test memory -/
def testMem32 : WasmNum.Memory.FlatMemory 32 :=
  {
    data := ByteArray.mk (Array.mk (List.replicate 65536 (0 : UInt8)))
    pageCount := 1
    maxLimit := none
    inv_dataSize := by native_decide
    inv_maxValid := by intro m hm; simp at hm
    inv_addrFits := by native_decide
    inv_maxFits := by intro m hm; simp at hm
  }

/-- Helper for creating a small 1-page test memory with max 2 pages -/
def testMem32WithMax : WasmNum.Memory.FlatMemory 32 :=
  {
    data := ByteArray.mk (Array.mk (List.replicate 65536 (0 : UInt8)))
    pageCount := 1
    maxLimit := some 2
    inv_dataSize := by native_decide
    inv_maxValid := by intro m hm; simp at hm; omega
    inv_addrFits := by native_decide
    inv_maxFits := by intro m hm; simp at hm; subst hm; native_decide
  }

end WasmTest
