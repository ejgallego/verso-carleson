import CarlesonBlueprint.Equations
import VersoBlueprint

open Verso Verso.Genre.Manual CarlesonBlueprint

#docs (Genre.Manual) uniqueEquations "Equations" :=
:::::::
{ref "later" (domain := CarlesonBlueprint.equation)}[the later identity]

{equation "earlier"}[$$`x = x`]

{ref "earlier" (domain := CarlesonBlueprint.equation)}[the earlier identity]

{equation "later"}[$$`y = y`]
:::::::

#docs (Genre.Manual) duplicateEquations "Duplicate equation" :=
:::::::
{equation "duplicate"}[$$`x = x`]

{ref "duplicate" (domain := CarlesonBlueprint.equation)}[the first identity]

{equation "duplicate"}[$$`y = y`]
:::::::

private def impls : ExtensionImpls := extension_impls%

#eval show IO Unit from do
  let errors ← IO.mkRef (#[] : Array String)
  let (blocks, state) ← Informal.traverseManualBlocks uniqueEquations.toPart.content impls
    (fun message => errors.modify (·.push message))
  unless (← errors.get).isEmpty do
    throw <| IO.userError s!"Valid equation references failed: {← errors.get}"
  for label in #["earlier", "later"] do
    unless (state.resolveDomainObject equationDomain label).isOk do
      throw <| IO.userError s!"Missing equation target: {label}"
  let preview ← Informal.renderManualBlocksHtmlWithState blocks impls state
    (logError := fun message => errors.modify (·.push message))
  for label in #["earlier", "later"] do
    let target ← IO.ofExcept <| state.resolveDomainObject equationDomain label
    if (preview.asString.splitOn s!" id=\"{target.htmlId}\"").length > 1 then
      throw <| IO.userError s!"Equation preview repeated the page target: {label}"
  unless (← errors.get).isEmpty do
    throw <| IO.userError s!"Equation preview rendering failed: {← errors.get}"
  let (_, rejected) ← Informal.traverseManualBlocks duplicateEquations.toPart.content impls
    (fun message => errors.modify (·.push message))
  unless (← errors.get).any (·.startsWith "Duplicate tag") do
    throw <| IO.userError "A reference between duplicate equation labels hid the conflict"
  let some target := rejected.getDomainObject? equationDomain "duplicate"
    | throw <| IO.userError "Duplicate rejection removed the accepted equation target"
  unless target.ids.size == 1 do
    throw <| IO.userError "Duplicate rejection still registered a second equation target"
