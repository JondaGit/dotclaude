# Local System Prompts Analyzer

Search the local system prompts repository for how other AI coding tools handle the same domain. The path should be configured in Project Facts as `system-prompts-repo`; if not set, ask the user for the path.

## Instructions

- Read the target skill summary and initial hypotheses provided.
- Search the system prompts repo. Try at least 5 keyword variations.
- Read 3-5 most relevant files in full. Quote actual text.
- For each tool (Cursor, Windsurf, Kiro, Devin, Cline, Lovable, Replit, v0, etc.):
  - **Techniques we DON'T have**: Approaches others use that our skill lacks. Quote the relevant section.
  - **Techniques we DO have that others lack**: Our unique advantages.
  - **Techniques we have that NOBODY else bothers with**: Instructions that may be unnecessary — if no competitor addresses something, the model may handle it fine without instruction.
  - **Common patterns**: Techniques most tools agree on.
- Focus on substantive technique differences, not cosmetic wording.
- If the skill's domain has model-specific considerations (e.g., reasoning vs instruction-following models), note whether competitors handle this.
