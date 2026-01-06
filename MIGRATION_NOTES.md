# Jekyll to Jackdaw Migration Notes

## 1. Project Initialization
* Run `jackdaw new <project_name>` to generate the standard directory structure:
  * `site/src`: Content
  * `site/templates`: ERB Templates
  * `site/assets`: Static files (images, css, favicons)

## 2. Template Conversion
* **Layouts**: Consolidate Jekyll layouts (default, page, etc.) into `site/templates/layout.html.erb`.
  * Replace `{{ content }}` with `<%= content %>`.
  * Replace `{{ page.title }}` with `<%= title %>`.
* **Partials**: Convert `{% include file.html %}` to `<%= render 'file' %>`.
  * Rename partial files to start with an underscore (e.g., `_nav.html.erb`).
* **Assets**: 
  * Move CSS/JS/Images to `site/assets/`.
  * **Important**: When referencing in HTML, omit `assets/`. 
    * `site/assets/styles.css` -> `<link href="/styles.css">`
    * `site/assets/img/logo.png` -> `<img src="/img/logo.png">`

## 3. Content Migration Strategies
* **File Extensions**: 
  * Regular pages: `.md` -> `.page.md`
  * Blog posts: `.md` -> `.blog.md` (Filename must start with `YYYY-MM-DD-`)
* **Frontmatter Handling**: 
  * Jackdaw renders the *first H1* as the page title.
  * **Task**: Strip YAML frontmatter (`--- ... ---`) and ensure the file starts with `# Page Title`.
* **Directory Structure**:
  * Keep the same folder structure in `site/src` to maintain URLs.
  * **Conflict Warning**: Do not create `topic.page.md` if you also have a folder named `topic/`. Instead, create `topic/index.page.md`.

## 4. Automation (Ruby Script)
For bulk migration of documentation, use a script to:
1. Iterate through source directories.
2. Read file content.
3. specific YAML frontmatter values (Title).
4. Rewrite file to destination with new header and `.page.md` extension.

## 5. Navigation & Indices
* Jackdaw does not automatically build navigation menus from folder structure.
* **Manual**: Edit `site/templates/_nav.html.erb`.
* **Auto-generated Indices**: Write scripts to generate index markdown files (e.g., "List of all Rules") if the content changes frequently.

## 6. Styling
* Jackdaw provides no default styling.
* Create a robust `styles.css` using CSS Variables for theming.
* Link fonts and stylesheets in the `<head>` of `layout.html.erb`.
