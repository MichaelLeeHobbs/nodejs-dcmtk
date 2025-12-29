# nodejs-dcmtk

Docker image based on Node.js Alpine with DCMTK (DICOM Toolkit) pre-installed and compiled with full library support.

## Features

- **Node.js** on Alpine Linux (minimal footprint)
- **DCMTK** (DICOM Toolkit) compiled from source with:
  - ✅ XML support (libxml2)
  - ✅ zlib compression
  - ✅ PNG output support (libpng)
  - ✅ TIFF output support (libtiff)
- Multiple DCMTK and Node.js version combinations available
- All DCMTK command-line tools pre-installed

## Supported Tags

Images are tagged with the pattern: `dcmtk{DCMTK_VERSION}-node{NODE_VERSION}`

**DCMTK Versions:** 3.6.7, 3.6.8, 3.6.9, 3.7.0  
**Node.js Versions:** 20.x, 22.x, 24.x (Alpine 3.23)

## Quick Start

```bash
# Pull the image
docker pull michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23

# Run interactively
docker run -it --rm michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23 sh

# Convert DICOM to PNG
docker run --rm -v $(pwd):/data michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23 \
  dcm2pnm --write-png /data/input.dcm /data/output.png

# Convert DICOM to TIFF
docker run --rm -v $(pwd):/data michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23 \
  dcm2pnm --write-tiff /data/input.dcm /data/output.tiff
```

## Available DCMTK Tools

All standard DCMTK command-line tools are available in `/usr/local/bin/`:

- **Conversion**: `dcm2json`, `dcm2pdf`, `dcm2pnm`, `dcm2xml`, `img2dcm`, `pdf2dcm`, `stl2dcm`, `xml2dcm`, `dcmj2pnm`*, `dcm2img`*
- **Compression**: `dcmcjpeg`, `dcmcjpls`, `dcmcrle`, `dcmdjpeg`, `dcmdjpls`, `dcmdrle`
- **Image Processing**: `dcmquant`, `dcmscale`, `dcmicmp`
- **Inspection**: `dcmdump`, `dcmftest`
- **Networking**: `dcmsend`, `dcmrecv`, `dcmqrscp`, `dcmqrti`
- **Print**: `dcmprscp`, `dcmprscu`, `dcmpsprt`
- And many more...

> **Note:** Tool availability varies by DCMTK version. For example, `dcmj2pnm` was replaced by `dcm2img` in version 3.6.9. Always refer to the [official DCMTK documentation](https://support.dcmtk.org/docs/) for version-specific tool information.

Run any tool with `--help` to see options:
```bash
docker run --rm michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23 dcm2pnm --help
```

## PNG/TIFF Output Options

The `dcm2pnm` tool supports multiple output formats:

```bash
# 8-bit or 24-bit PNG
dcm2pnm --write-png input.dcm output.png

# 16-bit or 48-bit PNG
dcm2pnm --write-16-bit-png input.dcm output.png

# 8-bit or 24-bit TIFF
dcm2pnm --write-tiff input.dcm output.tiff
```

## Use Cases

### As a Base Image

```dockerfile
FROM michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

CMD ["node", "index.js"]
```

### In Node.js Applications

```javascript
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function convertDicomToPng(inputPath, outputPath) {
  const { stdout, stderr } = await execPromise(
    `/usr/local/bin/dcm2pnm --write-png ${inputPath} ${outputPath}`
  );
  return stdout;
}
```

### With Docker Compose

```yaml
version: '3.8'
services:
  dicom-processor:
    image: michaelleehobbs/nodejs-dcmtk:dcmtk3.7.0-node24.12.0-alpine3.23
    volumes:
      - ./data:/data
      - ./app:/app
    working_dir: /app
    command: node process-dicom.js
```

## Environment Variables

- `DCMDICTPATH`: Pre-configured to `/usr/local/share/dcmtk/dicom.dic`

## Building From Source

```bash
git clone https://github.com/michaelleehobbs/nodejs-dcmtk
cd nodejs-dcmtk
docker build \
  --build-arg NODE_VER=24.12.0-alpine3.23 \
  --build-arg DCMTK_VER=3.7.0 \
  -t nodejs-dcmtk:custom .
```

## License

This image includes:
- **Node.js**: [MIT License](https://github.com/nodejs/node/blob/main/LICENSE)
- **DCMTK**: [BSD-style License](https://dicom.offis.de/dcmtk.php.en)
- **Alpine Linux**: Various open source licenses

## Links

- [DCMTK Official Documentation](https://support.dcmtk.org/)
- [DCMTK GitHub Repository](https://github.com/DCMTK/dcmtk)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Docker Hub](https://hub.docker.com/r/michaelleehobbs/nodejs-dcmtk)
- [GitHub Repository](https://github.com/michaelleehobbs/nodejs-dcmtk)

## Contributing

Issues and pull requests welcome at [github.com/michaelleehobbs/nodejs-dcmtk](https://github.com/michaelleehobbs/nodejs-dcmtk)

