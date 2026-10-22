import Lake
open Lake DSL

require VersoBlueprint from git "https://github.com/leanprover/verso-blueprint.git" @ "v4.35.0"
require Carleson from "Carleson"
require mathlib from git "https://github.com/leanprover-community/mathlib4.git" @ "27915224146782fd94b35028045fcd8548316205"

package CarlesonBlueprint where
  precompileModules := false
  leanOptions := #[
    ⟨`experimental.module, true⟩,
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`maxSynthPendingDepth, .ofNat 3⟩,
    ⟨`weak.verso.blueprint.math.lint, true⟩,
    ⟨`weak.verso.blueprint.externalCode.strictResolve, true⟩,
    ⟨`weak.verso.code.warnLineLength, .ofNat 0⟩
  ]

@[default_target]
lean_lib CarlesonBlueprint where

lean_exe «blueprint-gen» where
  root := `BlueprintMain
  supportInterpreter := true

@[test_driver]
lean_lib CarlesonBlueprintTests where
  srcDir := "tests"
  roots := #[`EquationReferences]
