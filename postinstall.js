#!/usr/bin/env node

/**
 * Post-install script for Claude Code Orchestrator Kit
 *
 * This script runs automatically after npm install and helps users
 * set up the kit properly.
 */

import { welcome } from './index.js';
import { existsSync } from 'fs';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Check if required files exist
 */
function checkInstallation() {
  const requiredPaths = [
    '.claude',
    '.claude/agents',
    '.claude/commands',
    '.claude/skills',
    'mcp',
    'CLAUDE.md',
    'README.md',
  ];

  const missing = requiredPaths.filter(
    path => !existsSync(join(__dirname, path))
  );

  if (missing.length > 0) {
    console.error('❌ Installation incomplete. Missing files:');
    missing.forEach(path => console.error(`   - ${path}`));
    process.exit(1);
  }

  return true;
}

/**
 * Main post-install routine
 */
async function main() {
  try {
    // Check installation integrity
    checkInstallation();

    // Display welcome message with setup instructions
    welcome();

    // Check if .env.local exists
    if (!existsSync(join(__dirname, '.env.local'))) {
      console.log('\n⚠️  Remember to create .env.local from .env.example\n');
    }

    // Success
    process.exit(0);
  } catch (error) {
    console.error('❌ Post-install failed:', error.message);
    process.exit(1);
  }
}

// Run post-install
main();
