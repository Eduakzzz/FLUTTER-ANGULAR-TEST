import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  // Registra HTTP para que los servicios puedan inyectarlo.
  providers: [provideBrowserGlobalErrorListeners(), provideHttpClient()],
};
