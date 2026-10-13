// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import { satteri } from '@astrojs/markdown-satteri';
import changelogPlugin from './src/plugins/changelog-plugin.mjs';

// https://astro.build/config
export default defineConfig({
	// Served by GitHub Pages as a project site: https://aamnah.github.io/dotfiles/
	// `base` makes every link and asset start with /dotfiles/ — without it the
	// site works locally but CSS, JS and search 404 on GitHub Pages.
	site: 'https://aamnah.github.io',
	base: '/dotfiles',
	// The changelog page imports ../CHANGELOG.md from the repo root. The dev
	// server only serves files inside docs/ by default, so without this the
	// page errors in `npm run dev` (the production build works either way).
	vite: { server: { fs: { allow: ['..'] } } },
	// Changelog layout: a coloured tag on every line (see the plugin file).
	// satteri() is Astro's default Markdown engine; naming it here only adds
	// the plugin.
	markdown: { processor: satteri({ hastPlugins: [changelogPlugin] }) },
	integrations: [
		starlight({
			// Fails the build on broken internal links or #anchors, so a renamed
			// heading can't silently break links from other pages
			plugins: [
				starlightLinksValidator({
					// Skip the "Jump to" links inside CHANGELOG.md (#20261013…). The
					// checker can't see the headings of a file imported into a page,
					// so it reports them all as broken, though they work on the site.
					// Every other link, in every file, is still checked.
					exclude: ({ file, link }) => file.endsWith('CHANGELOG.md') && link.startsWith('#'),
				}),
			],
			title: 'Dotfiles',
			description: 'Shell, editor and terminal configs for Linux and macOS, with an installer.',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/aamnah/dotfiles' }],
			// "Edit page" link at the bottom of every page
			editLink: { baseUrl: 'https://github.com/aamnah/dotfiles/edit/main/docs/' },
			lastUpdated: true,
			customCss: ['./src/styles/theme.css'],
			// Swap in our versions to add a high-contrast mode (see the files)
			components: {
				ThemeProvider: './src/components/ThemeProvider.astro',
				ThemeSelect: './src/components/ThemeSelect.astro',
			},
			// One page per config/app. Order here = order in the sidebar.
			sidebar: [
				{
					label: 'Get started',
					items: ['start/install', 'start/systems', 'start/what-gets-installed'],
				},
				{
					label: 'Shell',
					items: [
						'shell/overview',
						'shell/zsh',
						'shell/bash',
						'shell/aliases',
						'shell/functions',
						'shell/locale',
						'shell/colours',
						'shell/local-files',
					],
				},
				{
					label: 'Terminal',
					items: ['terminal/kitty', 'terminal/tmux', 'terminal/starship'],
				},
				{
					label: 'Editors',
					items: ['editors/nano', 'editors/vim', 'editors/neovim', 'editors/vscode'],
				},
				{
					label: 'Tools',
					items: ['tools/git', 'tools/tmuxp', 'tools/peaclock'],
				},
				{
					label: 'Reference',
					items: [
						'reference/troubleshooting',
						'reference/known-issues',
						'reference/installer-internals',
						'reference/contributing',
						'reference/changelog',
					],
				},
			],
		}),
	],
});
