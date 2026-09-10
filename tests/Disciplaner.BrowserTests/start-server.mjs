import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// Each run owns a new database and upload directory; never reuse user data.
const directory = mkdtempSync(join(tmpdir(), 'disciplaner-browser-'));
const project = fileURLToPath(new URL('../../src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj', import.meta.url));
console.log(`Browser test data: ${directory}`);
const child = spawn('dotnet', ['run', '--project', project, '--no-restore', '--no-launch-profile'], {
  stdio: 'inherit',
  env: {
    ...process.env, ASPNETCORE_ENVIRONMENT: 'Development',
    ASPNETCORE_URLS: 'http://127.0.0.1:5187',
    ConnectionStrings__DefaultConnection: `Data Source=${join(directory, 'test.db')}`,
    FileStorage__BasePath: join(directory, 'uploads'),
    Jwt__SecretKey: 'BrowserTestOnlySecretKeyAtLeast32Characters!',
    Logging__EventLog__LogLevel__Default: 'None',
    AdminSeed__Email: '', AdminSeed__Password: ''
  }
});
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => child.kill(signal));
child.on('exit', code => process.exit(code ?? 0));
child.on('error', error => { console.error(error); process.exit(1); });
