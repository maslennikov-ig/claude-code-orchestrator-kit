#!/usr/bin/env node

/**
 * Claude Code Orchestrator Kit
 *
 * Main entry point for the npm package.
 * This file provides programmatic access to the kit's utilities.
 */

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read package.json for version info
const packageJson = JSON.parse(
  readFileSync(join(__dirname, 'package.json'), 'utf-8')
);

/**
 * Get the version of the orchestrator kit
 */
export function getVersion() {
  return packageJson.version;
}

/**
 * Get the installation directory path
 */
export function getInstallPath() {
  return __dirname;
}

/**
 * Get paths to key directories
 */
export function getPaths() {
  return {
    root: __dirname,
    claude: join(__dirname, '.claude'),
    agents: join(__dirname, '.claude', 'agents'),
    commands: join(__dirname, '.claude', 'commands'),
    skills: join(__dirname, '.claude', 'skills'),
    mcp: join(__dirname, 'mcp'),
    docs: join(__dirname, 'docs'),
  };
}

/**
 * Display welcome message
 */
export function welcome() {
  console.log(`
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   🎼 Claude Code Orchestrator Kit v${packageJson.version}                 ║
║                                                                ║
║   Professional automation and orchestration system             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

📦 Package installed successfully!

🚀 Next Steps:

1. Set up environment variables:
   cp .env.example .env.local
   # Edit .env.local with your credentials

2. Choose MCP configuration:
   npm run setup
   # Or: bash switch-mcp.sh

3. Restart Claude Code to apply changes

📚 Documentation: ${packageJson.homepage}
💬 Issues: ${packageJson.bugs.url}

Happy coding with Claude! 🤖
`);
}

// If run directly from command line
if (process.argv[1] === __filename) {
  welcome();
}

// Export all utilities
export default {
  getVersion,
  getInstallPath,
  getPaths,
  welcome,
};
