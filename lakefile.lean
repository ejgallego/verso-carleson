import Lake
open Lake DSL

require VersoBlueprint from git "https://github.com/leanprover/verso-blueprint.git" @ "0e37300311c055dfb838a84ba195ea3751750572"
require Carleson from "Carleson"
require mathlib from git "https://github.com/leanprover-community/mathlib4.git" @ "b63493a4746b4651fceb3bcf3a4651cc36a4b8de"

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
