import { DecimalPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { Order } from './order.model';

@Component({
  selector: 'app-order-card',
  standalone: true,
  imports: [DecimalPipe],
  templateUrl: './order-card.component.html',
  styleUrl: './order-card.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OrderCardComponent {
  readonly order = input.required<Order>();
  readonly selected = input(false);
  readonly viewDetail = output<number>();
}
