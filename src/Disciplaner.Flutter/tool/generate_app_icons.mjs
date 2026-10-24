// Générateur d'icônes applicatives Disciplan.
//
// Rend le logo Disciplan (palette Neo-Linear, voir ux/disciplan_neo_linear/DESIGN.md)
// à toutes les tailles requises par les cibles Flutter :
//   - Android : mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher.png
//   - iOS     : Runner/Assets.xcassets/AppIcon.appiconset/*
//   - Web     : favicon + PWA icons (dont maskable)
//   - macOS   : Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png
//   - Windows : runner/resources/app_icon.ico
//
// Aucune dépendance : rendu par champs de distance signés (antialiasing exact)
// et encodage PNG/ICO manuel via le module zlib de Node.
//
// Usage :
//   node tool/generate_app_icons.mjs --design d        # génère tout avec le design "d"
//   node tool/generate_app_icons.mjs --preview          # écrit des aperçus dans tool/branding/

import { deflateSync } from 'node:zlib';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');

const args = process.argv.slice(2);
const previewOnly = args.includes('--preview');
const designArg = args.includes('--design') ? args[args.indexOf('--design') + 1] : 'd';

// ---------------------------------------------------------------------------
// Palette Neo-Linear
// ---------------------------------------------------------------------------
const TILE = hex('#1c1b19'); // primary-container
const GREEN = hex('#4edea3'); // tertiary-fixed-dim
const AMBER = hex('#fcbc24'); // secondary-fixed-dim
const BONE = hex('#fbf9f4'); // surface

const DESIGN = 1024;
const TILE_RADIUS = 232;

function hex(value) {
  return [
    parseInt(value.slice(1, 3), 16),
    parseInt(value.slice(3, 5), 16),
    parseInt(value.slice(5, 7), 16),
  ];
}

// ---------------------------------------------------------------------------
// Champs de distance signés
// ---------------------------------------------------------------------------
// Rectangle arrondi, rayons par coin [tr, br, tl, bl].
function sdRoundRect(px, py, cx, cy, hw, hh, r) {
  const qx = Math.abs(px - cx) - (hw - r);
  const qy = Math.abs(py - cy) - (hh - r);
  return Math.min(Math.max(qx, qy), 0) + Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) - r;
}

function sdRoundRectRadii(px, py, cx, cy, hw, hh, r) {
  const sx = px > cx ? 0 : 2;
  const sy = py > cy ? 0 : 1;
  const rr = r[sx + sy] ?? r[0];
  const qx = Math.abs(px - cx) - (hw - rr);
  const qy = Math.abs(py - cy) - (hh - rr);
  return Math.min(Math.max(qx, qy), 0) + Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) - rr;
}

// Pilule orientée (angle en degrés, direction du segment).
function pill(cx, cy, halfLen, halfW, angleDeg) {
  const a = (angleDeg * Math.PI) / 180;
  const cos = Math.cos(a);
  const sin = Math.sin(a);
  return (x, y) => {
    const dx = x - cx;
    const dy = y - cy;
    const rx = dx * cos + dy * sin;
    const ry = -dx * sin + dy * cos;
    return sdRoundRect(rx, ry, 0, 0, halfLen, halfW, halfW);
  };
}

const subtract = (a, b) => (x, y) => Math.max(a(x, y), -b(x, y));

// ---------------------------------------------------------------------------
// Designs (espace 1024x1024, centrés sur 512,512)
// Chaque forme : { color, sd(x, y) } ; la première forme est composée
// au-dessus de la tuile, les suivantes au-dessus de la précédente.
// ---------------------------------------------------------------------------
const DESIGNS = {
  // Trois barres ascendantes (progression de sprint).
  bars: {
    label: 'Barres ascendantes',
    shapes: [
      { color: GREEN, sd: (x, y) => sdRoundRect(x, y, 308, 628, 65, 136, 65) },
      { color: AMBER, sd: (x, y) => sdRoundRect(x, y, 512, 542, 65, 222, 65) },
      { color: BONE, sd: (x, y) => sdRoundRect(x, y, 716, 456, 65, 308, 65) },
    ],
    svg: `<rect x="243" y="492" width="130" height="272" rx="65" fill="#4edea3"/>
  <rect x="447" y="320" width="130" height="444" rx="65" fill="#fcbc24"/>
  <rect x="651" y="148" width="130" height="616" rx="65" fill="#fbf9f4"/>`,
  },

  // Monogramme D épuré.
  d: {
    label: 'Monogramme D',
    shapes: [
      {
        color: BONE,
        sd: subtract(
          (x, y) => sdRoundRectRadii(x, y, 512, 512, 170, 228, [170, 170, 78, 78]),
          (x, y) => sdRoundRectRadii(x, y, 524, 512, 62, 122, [62, 62, 34, 34]),
        ),
      },
    ],
    svg: `<path fill="#fbf9f4" fill-rule="evenodd" d="M342 284h216a170 170 0 0 1 170 170v116a170 170 0 0 1-170 170H342a78 78 0 0 1-78-78V362a78 78 0 0 1 78-78Zm96 106v244h106a62 62 0 0 0 62-62v-120a62 62 0 0 0-62-62H438Z"/>`,
  },

  // Monogramme D avec coche ambre dans la contrepoinque.
  dcheck: {
    label: 'Monogramme D + coche',
    shapes: [
      {
        color: BONE,
        sd: subtract(
          (x, y) => sdRoundRectRadii(x, y, 512, 512, 170, 228, [170, 170, 78, 78]),
          (x, y) => sdRoundRectRadii(x, y, 524, 512, 62, 122, [62, 62, 34, 34]),
        ),
      },
      { color: AMBER, sd: pill(490, 568, 30, 18, 61.7) },
      { color: AMBER, sd: pill(532, 517, 82, 18, -70) },
    ],
    svg: `<path fill="#fbf9f4" fill-rule="evenodd" d="M342 284h216a170 170 0 0 1 170 170v116a170 170 0 0 1-170 170H342a78 78 0 0 1-78-78V362a78 78 0 0 1 78-78Zm96 106v244h106a62 62 0 0 0 62-62v-120a62 62 0 0 0-62-62H438Z"/>
  <g transform="rotate(61.7 490 568)"><rect x="460" y="550" width="60" height="36" rx="18" fill="#fcbc24"/></g>
  <g transform="rotate(-70 532 517)"><rect x="450" y="499" width="164" height="36" rx="18" fill="#fcbc24"/></g>`,
  },
  list: {
    label: 'Liste',
    shapes: [
      { color: BONE, sd: (x, y) => sdRoundRect(x, y, 512, 384, 220, 48, 48) },
      { color: BONE, sd: (x, y) => sdRoundRect(x, y, 512, 512, 220, 48, 48) },
      { color: AMBER, sd: (x, y) => sdRoundRect(x, y, 422, 640, 130, 48, 48) },
    ],
    svg: `<rect x="292" y="336" width="440" height="96" rx="48" fill="#fbf9f4"/>
  <rect x="292" y="464" width="440" height="96" rx="48" fill="#fbf9f4"/>
  <rect x="292" y="592" width="260" height="96" rx="48" fill="#fcbc24"/>`,
  },

  // Coche de validation.
  check: {
    label: 'Coche',
    shapes: [
      { color: BONE, sd: pill(397, 621, 95, 65, 45) },
      { color: BONE, sd: pill(586, 509, 217, 65, -55.7) },
    ],
    svg: `<g transform="rotate(45 397 621)"><rect x="302" y="556" width="190" height="130" rx="65" fill="#fbf9f4"/></g>
  <g transform="rotate(-55.7 586 509)"><rect x="369" y="444" width="434" height="130" rx="65" fill="#fbf9f4"/></g>`,
  },
};

// ---------------------------------------------------------------------------
// Rendu
// ---------------------------------------------------------------------------
function coverage(dPx) {
  return Math.min(Math.max(0.5 - dPx, 0), 1);
}

function renderIcon(size, { design = 'bars', fullBleed = false, glyphScale = 1, glyphCx = 512, glyphCy = 512 } = {}) {
  const shapes = DESIGNS[design].shapes;
  const px = new Uint8Array(size * size * 4);
  const step = DESIGN / size;

  for (let y = 0; y < size; y++) {
    const dy = (y + 0.5) * step;
    for (let x = 0; x < size; x++) {
      const dx = (x + 0.5) * step;
      const o = (y * size + x) * 4;

      let aTile = 1;
      if (!fullBleed) {
        aTile = coverage(sdRoundRect(dx, dy, 512, 512, 512, 512, TILE_RADIUS) * (size / DESIGN));
      }

      let r = TILE[0], g = TILE[1], b = TILE[2], a = aTile;
      for (const shape of shapes) {
        const ux = (dx - glyphCx) / glyphScale + 512;
        const uy = (dy - glyphCy) / glyphScale + 512;
        const dPx = shape.sd(ux, uy) * glyphScale * (size / DESIGN);
        const c = coverage(dPx);
        if (c > 0) {
          r = shape.color[0] * c + r * (1 - c);
          g = shape.color[1] * c + g * (1 - c);
          b = shape.color[2] * c + b * (1 - c);
          a = c + a * (1 - c);
        }
      }

      px[o] = Math.round(r);
      px[o + 1] = Math.round(g);
      px[o + 2] = Math.round(b);
      px[o + 3] = Math.round(a * 255);
    }
  }
  return px;
}

// ---------------------------------------------------------------------------
// Encodage PNG (RGBA 8 bits, filtre 0)
// ---------------------------------------------------------------------------
const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c >>> 0;
  }
  return table;
})();

function crc32(bytes) {
  let c = 0xffffffff;
  for (const byte of bytes) c = CRC_TABLE[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  out.write(type, 4, 'ascii');
  data.copy(out, 8);
  out.writeUInt32BE(crc32(out.subarray(4, 8 + data.length)), 8 + data.length);
  return out;
}

function encodePng(rgba, size) {
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 6; // RGBA
  const raw = Buffer.alloc((size * 4 + 1) * size);
  for (let y = 0; y < size; y++) {
    raw[y * (size * 4 + 1)] = 0; // filtre "none"
    Buffer.from(rgba.buffer, y * size * 4, size * 4).copy(raw, y * (size * 4 + 1) + 1);
  }
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

// ---------------------------------------------------------------------------
// Encodage ICO (BMP 32 bits pour les petites tailles, PNG au-delà de 64)
// ---------------------------------------------------------------------------
function icoBmpEntry(rgba, size) {
  const maskStride = Math.ceil(size / 32) * 4;
  const maskSize = maskStride * size;
  const header = Buffer.alloc(40);
  header.writeUInt32LE(40, 0);
  header.writeInt32LE(size, 4);
  header.writeInt32LE(size * 2, 8); // hauteur doublée (XOR + masque AND)
  header.writeUInt16LE(1, 12);
  header.writeUInt16LE(32, 14);
  header.writeUInt32LE(size * size * 4 + maskSize, 20);

  const pixels = Buffer.alloc(size * size * 4);
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const src = (y * size + x) * 4;
      const dst = ((size - 1 - y) * size + x) * 4; // bottom-up, BGRA
      pixels[dst] = rgba[src + 2];
      pixels[dst + 1] = rgba[src + 1];
      pixels[dst + 2] = rgba[src];
      pixels[dst + 3] = rgba[src + 3];
    }
  }
  return Buffer.concat([header, pixels, Buffer.alloc(maskSize)]);
}

function encodeIco(sizes, design) {
  const entries = sizes.map((size) => {
    const rgba = renderIcon(size, { design, glyphScale: size < 48 ? 0.92 : 1 });
    const data = size > 64 ? encodePng(rgba, size) : icoBmpEntry(rgba, size);
    return { size, data };
  });

  const header = Buffer.alloc(6 + entries.length * 16);
  header.writeUInt16LE(0, 0);
  header.writeUInt16LE(1, 2); // type icône
  header.writeUInt16LE(entries.length, 4);

  let offset = header.length;
  entries.forEach((entry, i) => {
    const o = 6 + i * 16;
    header[o] = entry.size >= 256 ? 0 : entry.size;
    header[o + 1] = entry.size >= 256 ? 0 : entry.size;
    header[o + 4] = 1; // plans
    header[o + 5] = 0;
    header.writeUInt16LE(32, o + 6); // bits par pixel
    header.writeUInt32LE(entry.data.length, o + 8);
    header.writeUInt32LE(offset, o + 12);
    offset += entry.data.length;
  });

  return Buffer.concat([header, ...entries.map((e) => e.data)]);
}

// ---------------------------------------------------------------------------
// Sorties
// ---------------------------------------------------------------------------
const outputs = [];

function writeIcon(relPath, size, options) {
  const abs = join(ROOT, relPath);
  mkdirSync(dirname(abs), { recursive: true });
  writeFileSync(abs, encodePng(renderIcon(size, options), size));
  outputs.push(`${relPath} (${size}x${size})`);
}

function svgFor(design) {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${DESIGN} ${DESIGN}">
  <rect width="${DESIGN}" height="${DESIGN}" rx="${TILE_RADIUS}" fill="#1c1b19"/>
  ${DESIGNS[design].svg}
</svg>
`;
}

// ---------------------------------------------------------------------------
// Mode aperçu : une vignette 448 px par design + planche comparative
// ---------------------------------------------------------------------------
if (previewOnly) {
  const names = Object.keys(DESIGNS);
  const TILE_PREVIEW = 448;
  const GAP = 56;
  const sheetW = names.length * TILE_PREVIEW + (names.length - 1) * GAP;
  const sheet = new Uint8Array(sheetW * TILE_PREVIEW * 4);

  names.forEach((name, i) => {
    const tile = renderIcon(TILE_PREVIEW, { design: name });
    const x0 = i * (TILE_PREVIEW + GAP);
    for (let y = 0; y < TILE_PREVIEW; y++) {
      for (let x = 0; x < TILE_PREVIEW; x++) {
        const src = (y * TILE_PREVIEW + x) * 4;
        const dst = (y * sheetW + x0 + x) * 4;
        sheet[dst] = tile[src];
        sheet[dst + 1] = tile[src + 1];
        sheet[dst + 2] = tile[src + 2];
        sheet[dst + 3] = tile[src + 3];
      }
    }
    const rel = `tool/branding/preview_${name}.png`;
    writeFileSync(join(ROOT, rel), encodePng(tile, TILE_PREVIEW));
    console.log(`${rel} — ${DESIGNS[name].label}`);
  });

  // La planche encode une image non carrée : on passe par un buffer RGBA brut.
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(sheetW, 0);
  ihdr.writeUInt32BE(TILE_PREVIEW, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const raw = Buffer.alloc((sheetW * 4 + 1) * TILE_PREVIEW);
  for (let y = 0; y < TILE_PREVIEW; y++) {
    raw[y * (sheetW * 4 + 1)] = 0;
    Buffer.from(sheet.buffer, y * sheetW * 4, sheetW * 4).copy(raw, y * (sheetW * 4 + 1) + 1);
  }
  const sheetPng = Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
  writeFileSync(join(ROOT, 'tool/branding/preview_all.png'), sheetPng);
  console.log(`tool/branding/preview_all.png — planche ${names.length} designs, ordre : ${names.join(', ')}`);
  process.exit(0);
}

// ---------------------------------------------------------------------------
// Génération complète
// ---------------------------------------------------------------------------
const design = designArg;
if (!DESIGNS[design]) {
  console.error(`Design inconnu : ${design}. Disponibles : ${Object.keys(DESIGNS).join(', ')}`);
  process.exit(1);
}

// Android.
const androidDensities = { mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 };
for (const [density, size] of Object.entries(androidDensities)) {
  writeIcon(`android/app/src/main/res/mipmap-${density}/ic_launcher.png`, size, { design });
}

// iOS.
const iosAppIconSet = {
  'Icon-App-20x20@1x.png': 20,
  'Icon-App-20x20@2x.png': 40,
  'Icon-App-20x20@3x.png': 60,
  'Icon-App-29x29@1x.png': 29,
  'Icon-App-29x29@2x.png': 58,
  'Icon-App-29x29@3x.png': 87,
  'Icon-App-40x40@1x.png': 40,
  'Icon-App-40x40@2x.png': 80,
  'Icon-App-40x40@3x.png': 120,
  'Icon-App-60x60@2x.png': 120,
  'Icon-App-60x60@3x.png': 180,
  'Icon-App-76x76@1x.png': 76,
  'Icon-App-76x76@2x.png': 152,
  'Icon-App-83.5x83.5@2x.png': 167,
  'Icon-App-1024x1024@1x.png': 1024,
};
for (const [filename, size] of Object.entries(iosAppIconSet)) {
  writeIcon(`ios/Runner/Assets.xcassets/AppIcon.appiconset/${filename}`, size, { design });
}

// Web : maskables en fond plein, motif réduit dans la zone sûre.
writeIcon('web/favicon.png', 32, { design });
writeIcon('web/icons/Icon-192.png', 192, { design });
writeIcon('web/icons/Icon-512.png', 512, { design });
writeIcon('web/icons/Icon-maskable-192.png', 192, { design, fullBleed: true, glyphScale: 0.62 });
writeIcon('web/icons/Icon-maskable-512.png', 512, { design, fullBleed: true, glyphScale: 0.62 });

// macOS.
for (const size of [16, 32, 64, 128, 256, 512, 1024]) {
  writeIcon(`macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_${size}.png`, size, { design });
}

// Windows.
const icoPath = 'windows/runner/resources/app_icon.ico';
mkdirSync(join(ROOT, 'windows/runner/resources'), { recursive: true });
writeFileSync(join(ROOT, icoPath), encodeIco([16, 24, 32, 48, 64, 128, 256], design));
outputs.push(`${icoPath} (16..256, BMP 32 bits + PNG)`);

// Masters de référence.
writeIcon('tool/branding/disciplan_logo_1024.png', 1024, { design });
mkdirSync(join(ROOT, 'tool/branding'), { recursive: true });
writeFileSync(join(ROOT, 'tool/branding/disciplan_logo.svg'), svgFor(design));
outputs.push('tool/branding/disciplan_logo.svg (source)');

console.log(`Design : ${DESIGNS[design].label}\n`);
console.log(outputs.join('\n'));
