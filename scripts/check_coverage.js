const fs = require('fs');
const path = require('path');

const lcovPath = path.resolve(__dirname, '../frontend/coverage/lcov.info');
if (!fs.existsSync(lcovPath)) {
  console.error('lcov.info not found at:', lcovPath);
  process.exit(1);
}

const content = fs.readFileSync(lcovPath, 'utf8');
let totalLF = 0;
let totalLH = 0;
let skip = false;

for (const line of content.split('\n')) {
  if (line.startsWith('SF:')) {
    skip = line.endsWith('.g.dart');
  }
  if (!skip) {
    if (line.startsWith('LF:')) totalLF += parseInt(line.slice(3).trim(), 10);
    if (line.startsWith('LH:')) totalLH += parseInt(line.slice(3).trim(), 10);
  }
}

if (totalLF === 0) {
  console.error('No lines found in coverage report.');
  process.exit(1);
}

const pct = (totalLH / totalLF) * 100;
console.log(`Frontend Code Coverage: ${pct.toFixed(2)}% (Threshold: >= 70.0%)`);

if (pct < 70.0) {
  console.error(`::error::Code coverage (${pct.toFixed(2)}%) is below the required 70.0% threshold.`);
  process.exit(1);
}

console.log('Code coverage check passed successfully!');
