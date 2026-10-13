// Markdown plugin: reshapes CHANGELOG.md into tagged release notes while the
// docs site is built.
//
// Written for Sätteri, Astro's Markdown engine. A "hast plugin" edits the
// page's HTML tree (hast = HTML syntax tree) before it becomes HTML.
//
// CHANGELOG.md stays plain Markdown, so it still reads well on GitHub:
//
//   ## 2026.10.13
//   **October 13, 2026** · [Compare changes](…)
//   **Added**
//   - line one
//
// On the site, this plugin turns that into:
//   - a header row: version on the left, date on the right
//   - a coloured tag in front of every line ("Added", "Fixed" …), coloured per
//     group by the .cl-<group> classes in src/styles/theme.css
//
// Without it the page still works, just as plain headings and lists.

const isElement = (node, tagName) => node?.type === 'element' && node.tagName === tagName;

// A plain copy of a node. The tree we're handed is read-only, so new nodes are
// built from copies of the old ones.
const copy = (node) => JSON.parse(JSON.stringify(node));

const element = (tagName, className, children) => ({
	type: 'element',
	tagName,
	properties: className ? { className } : {},
	children,
});

// The real elements of a list of nodes, skipping the blank text between them
const elementsOf = (nodes) => nodes.filter((node) => node.type === 'element');

// A paragraph that is only one bold word, like **Added**: returns the word,
// else null. (The date line also starts with bold text, but has a link after
// it, so it doesn't count.)
function groupLabel(node, ctx) {
	if (!isElement(node, 'p')) return null;
	const meaningful = node.children.filter((child) => !(child.type === 'text' && !child.value.trim()));
	if (meaningful.length !== 1 || !isElement(meaningful[0], 'strong')) return null;
	return ctx.textContent(meaningful[0]).trim() || null;
}

const changelogLayout = {
	name: 'changelog-layout',

	// Runs once on the whole page, so it can look at neighbours (heading → date
	// line, label → list), which a per-element visitor can't
	before(root, ctx) {
		const blocks = elementsOf(root.children);

		blocks.forEach((node, i) => {
			const next = blocks[i + 1];

			// Version heading + the date line under it → one header row
			if (isElement(node, 'h2') && isElement(next, 'p')) {
				ctx.replaceNode(node, element('header', ['cl-release'], [copy(node), copy(next)]));
				ctx.removeNode(next);
				return;
			}

			// **Added** + the list after it → one list, each line tagged "Added"
			const label = groupLabel(node, ctx);
			if (!label || !isElement(next, 'ul')) return;

			const group = label.toLowerCase(); // "Added" → cl-added
			const items = elementsOf(next.children).map((item) =>
				element('li', null, [
					element('span', ['cl-tag'], [{ type: 'text', value: label }]),
					element('span', ['cl-text'], copy(item.children)),
				]),
			);
			ctx.replaceNode(next, element('ul', ['cl-list', `cl-${group}`], items));
			// Drop the **Added** paragraph: every line now carries the label
			ctx.removeNode(node);
		});
	},
};

// Only for CHANGELOG.md; every other page is left alone (null = no plugin)
export default (file) => (file.fileURL?.pathname.endsWith('/CHANGELOG.md') ? changelogLayout : null);
