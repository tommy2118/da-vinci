#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { hydrateState, starterFiles } from "../rockdrill.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, "..");
const defaultWorkshopRoot = path.resolve(projectRoot, "..");
const defaultRcTemplate = path.join(defaultWorkshopRoot, "templates", "slice", ".workshoprc.tmpl");
const defaultWorkshopBin = path.join(defaultWorkshopRoot, "bin", "workshop");

main();

function main() {
  const options = parseArgs(process.argv.slice(2));

  if (options.help || !options.stateFile) {
    printUsage();
    process.exitCode = options.help ? 0 : 64;
    return;
  }

  const state = hydrateState(JSON.parse(readFileSync(options.stateFile, "utf8")));
  const files = starterFiles(state);
  const missionPath = files.find((file) => file.path.endsWith("/MISSION.md"))?.path;
  const bodyPlanPath = files.find((file) => file.path.endsWith("/BODY_PLAN.md"))?.path;

  if (!missionPath || !bodyPlanPath) {
    err("starter file set is incomplete");
    process.exitCode = 1;
    return;
  }

  const missionDir = missionPath.split("/")[0];
  const sliceDir = path.dirname(bodyPlanPath);
  const sliceRoot = path.join(options.workshopRoot, sliceDir);
  const missionRoot = path.join(options.workshopRoot, missionDir);
  const rcPath = path.join(sliceRoot, ".workshoprc");

  const existingConflict = files.find((file) => {
    const target = path.join(options.workshopRoot, file.path);
    return existsSync(target) && readFileSync(target, "utf8") !== file.content;
  });

  if (existingConflict && !options.force) {
    err(`refusing to overwrite existing file without --force: ${existingConflict.path}`);
    process.exitCode = 1;
    return;
  }

  if (options.dryRun) {
    printPlan({ missionRoot, sliceRoot, files, rcPath, options });
    return;
  }

  mkdirSync(missionRoot, { recursive: true });
  mkdirSync(path.join(sliceRoot, "spec"), { recursive: true });

  for (const file of files) {
    const target = path.join(options.workshopRoot, file.path);
    mkdirSync(path.dirname(target), { recursive: true });
    writeFileSync(target, file.content);
  }

  if (!existsSync(rcPath) && existsSync(options.rcTemplate)) {
    writeFileSync(rcPath, readFileSync(options.rcTemplate, "utf8"));
  }

  out(`Bootstrapped mission: ${missionDir}`);
  out(`Slice directory: ${sliceDir}`);

  if (options.launchTmux) {
    const result = spawnSync(options.workshopBin, [sliceDir], {
      cwd: options.workshopRoot,
      stdio: "inherit",
    });
    process.exitCode = result.status ?? 0;
    return;
  }

  out(`Next: ${options.workshopBin} ${sliceDir}`);
}

function parseArgs(args) {
  const options = {
    stateFile: "",
    workshopRoot: defaultWorkshopRoot,
    rcTemplate: defaultRcTemplate,
    workshopBin: defaultWorkshopBin,
    dryRun: false,
    force: false,
    launchTmux: false,
    help: false,
  };

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];

    switch (arg) {
      case "--dry-run":
        options.dryRun = true;
        break;
      case "--force":
        options.force = true;
        break;
      case "--launch-tmux":
        options.launchTmux = true;
        break;
      case "--workshop-root":
        options.workshopRoot = path.resolve(args[index + 1]);
        index += 1;
        break;
      case "--help":
      case "-h":
        options.help = true;
        break;
      default:
        if (arg.startsWith("--")) {
          err(`unknown option: ${arg}`);
          process.exitCode = 64;
          return options;
        }
        if (!options.stateFile) {
          options.stateFile = path.resolve(arg);
          break;
        }
        err(`unexpected argument: ${arg}`);
        process.exitCode = 64;
        return options;
    }
  }

  return options;
}

function printPlan({ missionRoot, sliceRoot, files, rcPath, options }) {
  out("Dry run only.");
  out(`Workshop root: ${options.workshopRoot}`);
  out(`Mission dir: ${missionRoot}`);
  out(`Slice dir: ${sliceRoot}`);
  out(`.workshoprc template: ${options.rcTemplate}`);
  out("");
  out("Files to write:");
  for (const file of files) {
    out(`- ${file.path}`);
  }
  out("");
  out(`Will create .workshoprc if missing: ${rcPath}`);
  if (options.launchTmux) {
    out(`Will launch tmux with: ${options.workshopBin} ${path.relative(options.workshopRoot, sliceRoot)}`);
  }
}

function printUsage() {
  out(`usage: node tools/bootstrap-workshop.mjs <state-file.json> [--dry-run] [--force] [--launch-tmux] [--workshop-root PATH]

Reads a Visual Rock Drill state export, creates the workshop mission/slice
directories, writes the drilled artifacts, and can launch the tmux workshop
session for the slice.`);
}

function out(line) {
  process.stdout.write(`${line}\n`);
}

function err(line) {
  process.stderr.write(`${line}\n`);
}
