import { ChangeDetectionStrategy, Component } from '@angular/core';
import { OrdersPageComponent } from './features/orders/orders-page.component';

// @Component define selector, template y dependencias de la vista.
@Component({
  selector: 'app-root',
  imports: [OrdersPageComponent],
  templateUrl: './app.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
// export permite importar esta clase desde otros archivos.
export class App {}
