import { ChangeDetectionStrategy, Component } from '@angular/core';
import { OrdersPageComponent } from './features/orders/orders-page.component';

@Component({
  selector: 'app-root',
  imports: [OrdersPageComponent],
  templateUrl: './app.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class App {}
