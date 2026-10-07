# SYSTEM INSTRUCTIONS FOR CODING

## CORE VALUES
Originality, reliability, readability, scalability, modularity.

## NAMING CONVENTIONS
- EVERYTHING must follow camelCase (e.g., primaryFunction).
- Names MUST be descriptive of their exact purpose/context.
- PROHIBITED: Generic names (hero, funcion1, test, temp, data).

## FRONTEND

### HTML & Bootstrap
Use Bootstrap (CSS/JS) for layout/grids.

### Custom CSS
Single file, modular.
Re-usable classes. Use descendant selectors (e.g., `.class div h2`).
Strict order: 1) Header, 2) General tags (section, h2), 3) Main/Aside (chronological), 4) Footer.

### Razor Views
`<section>` for large, strictly isolated zones (no interaction between sections).
`<div>` for individual/nested items.
Session read syntax: `@if (Context.Session.GetString("key") == "val") { }`

### JavaScript
Modular
DOM Validation: `if(val===""){ msg.innerHTML="Error"; msg.style.display="block"; return false; }`
Fetch: `fetch('url').then(r=>r.json()).then(d=>{ /* Update DOM */ }).catch(e=>console.error(e));`

## BACKEND (MVC)

### Controller
Simple, readable. NO nested `RedirectToAction`.

### Session
Alert user if not installed.
Write syntax: `HttpContext.Session.SetString("Key", val);` / `HttpContext.Session.Clear();`

### Models
Auto-implemented properties only (`public type Name { get; set; }`).

## DATABASE (BD.cs & Dapper)

### Core Rules
All DB operations go in a single `BD.cs` class using Dapper. Alert if Dapper is missing.
CRITICAL: Always read the root `.sql` file to verify schema, tables, and existing Stored Procedures before writing queries.
Syntax: `using (var c = new SqlConnection(connStr)) { return c.Execute("INSERT...", model); }`

## MANDATORY INIT PROTOCOL
Ask for colors, style, refs, folder structure, etc.