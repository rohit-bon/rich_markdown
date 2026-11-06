## 1.1.0

- **Robust LaTeX Tokenizer**:
  - Full support for standard LaTeX delimiter pairs:
    - Inline equations: `$...$` and `\(...\)`
    - Block equations: `$$...$$` and `\[...\]`
  - Code protection: LaTeX expressions inside fenced code blocks (` ``` ` or `~~~`), inline code spans, and HTML `<pre>` / `<code>` blocks remain literal code.
  - Currency protection: Currency values such as `$100`, `$100.50`, `$10-$20`, and `$10, $20, and $30` are preserved as literal text.
  - Escaped delimiter support: Delimiters escaped with backslashes (such as `\$`, `\\$`, `\\(`, and `\\[`) are handled correctly.
  - Support for multiple equations in the same paragraph and multiline block equations.
- **Decoupled Architecture**:
  - Clear separation of parsing logic from Flutter widget rendering:
    - `LatexToken` & `LatexTokenType`: Structured data models representing text, inline math, and block math.
    - `LatexTokenizer`: Streaming-safe tokenizer with robust delimiter and boundary detection.
    - `LatexProcessor`: Base64-URL encoding, safe decoding, and HTML math tag processing.
    - `MarkdownProcessor`: Converts Markdown and HTML into HTML with preserved LaTeX placeholders.
    - `RichMarkdownView`: Clean Flutter rendering widget supporting custom styling and tag extensions.
- **Streaming-Safe Parsing**:
  - Incomplete and progressively arriving expressions remain as text without throwing exceptions or crashing the parser during streaming.
- **Error Handling and Fallbacks**:
  - Added `mathErrorBuilder` callback to `RichMarkdownView` for customizable rendering of malformed LaTeX expressions.
  - Safe decoding fallbacks ensuring invalid Base64 or unsupported TeX commands fail gracefully.
- **Automated Test Coverage**:
  - 76+ automated unit, integration, and widget tests covering all edge cases, regression scenarios, and streaming workflows.
  - Performance benchmarks validating sub-second processing for high-volume text.

## 1.0.0

- First stable release of Rich Markdown.
- Support for Markdown, LaTeX, and HTML content.
- Added inline and block mathematical equation rendering.
- Added customizable text styling and link tap callbacks.
- Added an example application demonstrating supported content types.
- Improved handling of Markdown and LaTeX for AI chat use cases.

## 0.1.0

- Initial release.
- Added Markdown rendering.
- Added LaTeX inline and block rendering.
- Added HTML rendering.
- Added customizable text styles and link callbacks.
