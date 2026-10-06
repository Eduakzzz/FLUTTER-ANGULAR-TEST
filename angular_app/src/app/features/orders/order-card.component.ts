import { DecimalPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { Order } from './order.model';

@Component({
  selector: 'app-order-card',
  standalone: true,
  imports: [DecimalPipe],
  templateUrl: './order-card.component.html',
  styleUrl: './order-card.component.css',
  // OnPush reacciona a inputs, Signals y eventos con menos comprobaciones.
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OrderCardComponent {
  // Input obligatorio del padre; <Order> declara su tipo.
  readonly order = input.required<Order>();
  readonly selected = input(false);
  // Output: envía el ID al padre como número.
  readonly viewDetail = output<number>();
}
