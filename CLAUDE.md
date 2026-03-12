# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image project that combines Node.js Alpine with DCMTK (DICOM Toolkit) pre-compiled. Builds and publishes multi-version images to Docker Hub as `michaelleehobbs/nodejs-dcmtk:dcmtk-{VERSION}-nodejs-{VERSION}`.

## Build & Test Commands

```bash
npm run build              # Regenerate GitHub Actions workflow from Handlebars templates
npm run test:build         # Build test image: Node 18.19.1 + DCMTK 3.6.7
npm run test:build2        # Build test image: Node 22.4.0 + DCMTK 3.6.8
npm run start:image:sleep  # Run test container for interactive debugging

# Manual local build
docker build --build-arg NODE_VER=24.12.0-alpine3.23 --build-arg DCMTK_VER=3.7.0 -t nodejs-dcmtk:test .

# Windows local build/test scripts
tools/localBuild.bat
tools/localTest.bat
```

## Architecture

### Dockerfile (multi-stage build)

**Builder stage** (Alpine 3.18): Installs dev tools (g++, make, cmake), clones DCMTK from GitHub, compiles with XML/zlib/PNG/TIFF support enabled, collects artifacts into `/out`.

**Final stage** (Node.js Alpine): Copies compiled DCMTK binaries from builder, installs only runtime libs (libxml2, zlib, libpng, tiff), sets `DCMDICTPATH=/usr/local/share/dcmtk/dicom.dic`.

Build args: `NODE_VER` (e.g. `24.12.0-alpine3.23`), `DCMTK_VER` (e.g. `3.7.0`).

### Workflow Generator (`src/`)

`src/index.js` uses Handlebars to generate `.github/workflows/dockerimage.yml` from `src/workflow.template`. Run `npm run build` after modifying templates or version lists.

### CI/CD

GitHub Actions triggers on every push. Matrix strategy builds all DCMTK × Node.js version combinations in parallel on `ubuntu-22.04` using `docker/build-push-action@v4` with BuildKit. Pushes to Docker Hub using `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets.

## Current Version Matrix

- **DCMTK:** 3.6.7, 3.6.8, 3.6.9, 3.7.0
- **Node.js:** 20.19.6, 22.21.1, 24.12.0 (all Alpine 3.23)

To add versions: update the matrix in `src/index.js` and run `npm run build`, or edit `.github/workflows/dockerimage.yml` directly.

## Commit Style

Conventional commits: `feat:`, `fix:`, `docs:`, etc.
