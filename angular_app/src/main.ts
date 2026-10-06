// import { ... } selecciona símbolos; ./ indica un archivo local.
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { App } from './app/app';

// Arranca el componente raíz con sus dependencias.
bootstrapApplication(App, appConfig).catch((err) => console.error(err));
