const fs = require('fs');
const path = require('path');

const lcovPath = path.resolve(__dirname, '../frontend/coverage/lcov.info');
const outDir = path.resolve(__dirname, '../frontend/coverage/html');

if (!fs.existsSync(lcovPath)) {
  console.error('lcov.info not found at', lcovPath);
  process.exit(1);
}

if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

const content = fs.readFileSync(lcovPath, 'utf8');
const lines = content.split('\n');

const files = [];
let currentFile = null;
let currentLF = 0;
let currentLH = 0;

for (const line of lines) {
  const trimmed = line.trim();
  if (trimmed.startsWith('SF:')) {
    currentFile = trimmed.substring(3);
    currentLF = 0;
    currentLH = 0;
  } else if (trimmed.startsWith('LF:')) {
    currentLF = parseInt(trimmed.substring(3), 10);
  } else if (trimmed.startsWith('LH:')) {
    currentLH = parseInt(trimmed.substring(3), 10);
    if (currentFile && !currentFile.endsWith('.g.dart')) {
      const pct = currentLF > 0 ? (currentLH / currentLF) * 100 : 0;
      files.push({
        file: currentFile,
        display: path.basename(currentFile),
        dir: path.dirname(currentFile).replace(/\\/g, '/'),
        lf: currentLF,
        lh: currentLH,
        pct: pct
      });
    }
  }
}

// Sort by directory and filename
files.sort((a, b) => a.file.localeCompare(b.file));

const totalLF = files.reduce((sum, f) => sum + f.lf, 0);
const totalLH = files.reduce((sum, f) => sum + f.lh, 0);
const totalPct = totalLF > 0 ? ((totalLH / totalLF) * 100).toFixed(1) : 0;

const getColor = (pct) => {
  if (pct >= 85) return '#2e7d32'; // green
  if (pct >= 70) return '#f57c00'; // yellow/amber
  return '#d32f2f'; // red
};

const getBadgeColor = (pct) => {
  if (pct >= 85) return '#e8f5e9';
  if (pct >= 70) return '#fff3e0';
  return '#ffebee';
};

const rows = files.map(f => {
  const pctStr = f.pct.toFixed(1) + '%';
  const color = getColor(f.pct);
  const bg = getBadgeColor(f.pct);
  return `
    <tr>
      <td style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; font-family: monospace;">
        <span style="color: #666; font-size: 11px;">${f.dir}/</span><br/>
        <strong>${f.display}</strong>
      </td>
      <td style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; text-align: center;">
        <span style="background: ${bg}; color: ${color}; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 13px;">
          ${pctStr}
        </span>
      </td>
      <td style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; text-align: right; font-family: monospace;">
        ${f.lh} / ${f.lf}
      </td>
      <td style="padding: 8px 12px; border-bottom: 1px solid #e0e0e0; width: 140px;">
        <div style="background: #e0e0e0; border-radius: 4px; height: 10px; overflow: hidden;">
          <div style="background: ${color}; width: ${f.pct}%; height: 100%;"></div>
        </div>
      </td>
    </tr>
  `;
}).join('');

const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>LCOV - Code Coverage Report - FM-EAA Frontend</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 24px; background: #f8f9fa; color: #202124; }
    .container { max-width: 1000px; margin: 0 auto; background: #fff; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 24px; }
    h1 { margin-top: 0; font-size: 24px; color: #1a73e8; display: flex; align-items: center; gap: 8px; }
    .summary-card { display: flex; gap: 16px; margin: 20px 0 28px 0; }
    .stat-box { flex: 1; padding: 16px 20px; border-radius: 8px; background: #f1f3f4; border-left: 4px solid #1a73e8; }
    .stat-box.highlight { background: ${getBadgeColor(totalPct)}; border-left: 4px solid ${getColor(totalPct)}; }
    .stat-label { font-size: 12px; color: #5f6368; text-transform: uppercase; font-weight: bold; letter-spacing: 0.5px; }
    .stat-val { font-size: 32px; font-weight: bold; color: ${getColor(totalPct)}; margin-top: 4px; }
    .stat-sub { font-size: 13px; color: #5f6368; margin-top: 4px; }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; }
    th { text-align: left; padding: 12px; background: #f1f3f4; font-size: 13px; color: #3c4043; border-bottom: 2px solid #dadce0; }
    .legend { display: flex; gap: 16px; font-size: 12px; color: #5f6368; margin-top: 16px; padding: 8px 12px; background: #f8f9fa; border-radius: 4px; }
    .dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>📊 LCOV Code Coverage Report</h1>
    <p style="color: #5f6368; font-size: 14px; margin-bottom: 20px;">
      Target: <code>FM-EAA Flutter Frontend</code> • Generated on <strong>${new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' })} ICT</strong>
    </p>

    <div class="summary-card">
      <div class="stat-box highlight">
        <div class="stat-label">Overall Line Coverage</div>
        <div class="stat-val">${totalPct}%</div>
        <div class="stat-sub">${totalLH.toLocaleString()} of ${totalLF.toLocaleString()} lines hit</div>
      </div>
      <div class="stat-box">
        <div class="stat-label">Files Tested</div>
        <div class="stat-val" style="color: #202124;">${files.length}</div>
        <div class="stat-sub">Excluding generated Drift code (*.g.dart)</div>
      </div>
      <div class="stat-box">
        <div class="stat-label">Rubric Target Status</div>
        <div class="stat-val" style="color: ${totalPct >= 70 ? '#2e7d32' : '#f57c00'}; font-size: 24px; padding-top: 6px;">
          ${totalPct >= 70 ? '✅ Passed (≥ 70%)' : '⏳ In Progress'}
        </div>
        <div class="stat-sub">${totalPct >= 70 ? 'Meets 5/5 score rubric' : 'Goal: ≥ 70.0%'}</div>
      </div>
    </div>

    <div class="legend">
      <span><span class="dot" style="background: #2e7d32;"></span> High Coverage (≥ 85%)</span>
      <span><span class="dot" style="background: #f57c00;"></span> Medium (70% - 84%)</span>
      <span><span class="dot" style="background: #d32f2f;"></span> Needs Test (&lt; 70%)</span>
    </div>

    <table>
      <thead>
        <tr>
          <th>Source File</th>
          <th style="text-align: center;">Coverage</th>
          <th style="text-align: right;">Lines Hit / Total</th>
          <th>Coverage Bar</th>
        </tr>
      </thead>
      <tbody>
        ${rows}
      </tbody>
    </table>
  </div>
</body>
</html>
`;

fs.writeFileSync(path.join(outDir, 'index.html'), html, 'utf8');
console.log('Successfully generated HTML report at:', path.join(outDir, 'index.html'));

