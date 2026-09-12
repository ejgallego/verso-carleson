import VersoManual
import VersoBlueprint.Lib.HoverRender

open Lean Verso Doc Elab Genre Manual ArgParse

namespace CarlesonBlueprint

/-- Equation labels belong to the document, independently of Blueprint nodes. -/
def equationDomain : Name := `CarlesonBlueprint.equation

inline_extension Inline.equation (label : String) where
  data := toJson label
  traverse id data _ := do
    let .ok label := fromJson? (α := String) data
      | reportError "Malformed equation label"
        return none
    let some _ ← providedTag id (← read).path s!"--equation-{label}"
      | return none
    modify (·.saveDomainObject equationDomain label id)
    pure none
  toHtml := some <| fun go id _ content => do
    let state ← Verso.Doc.Html.HtmlT.state
    let inPreview ← Informal.HoverRender.inInlinePreviewRender
    let attrs := if inPreview then #[] else state.htmlId id
    pure <| .tag "span" attrs (.seq (← content.mapM go))
  toTeX := some <| fun go id _ content => do
    let some target := (← Verso.Doc.TeX.state).externalTags[id]?
      | reportError "Missing equation target; traverse the document before rendering"
        return .empty
    let label := Verso.Output.TeX.labelForTeX target.htmlId
    pure <| .seq #[.raw ("\\phantomsection\\label{" ++ label ++ "}"), .seq (← content.mapM go)]

structure EquationConfig where
  label : String

instance {m : Type → Type} [Monad m] [MonadError m] : FromArgs EquationConfig m where
  fromArgs := EquationConfig.mk <$> .positional `label .string

/--
Wrap a displayed equation with a document target. Reference it with
`{ref "label" (domain := CarlesonBlueprint.equation)}[link text]`.
-/
@[role]
def equation : RoleExpanderOf EquationConfig
  | { label }, content => do
    let content ← content.mapM elabInline
    ``(Verso.Doc.Inline.other (Inline.equation $(quote label)) #[$content,*])

end CarlesonBlueprint
