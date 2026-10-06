import { DecimalPipe } from '@angular/common';
import {
  afterNextRender,
  ChangeDetectionStrategy,
  Component,
  computed,
  ElementRef,
  inject,
  Injector,
  signal,
  viewChild,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { catchError, map, of, startWith, Subject, switchMap } from 'rxjs';
import { Order, OrdersResponse } from './order.model';
import { OrderCardComponent } from './order-card.component';
import { OrdersService } from './orders.service';

type OrdersState =
  | { readonly status: 'loading' }
  | { readonly status: 'error' }
  | { readonly status: 'success'; readonly response: OrdersResponse };

@Component({
  selector: 'app-orders-page',
  standalone: true,
  imports: [DecimalPipe, OrderCardComponent],
  templateUrl: './orders-page.component.html',
  styleUrl: './orders-page.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OrdersPageComponent {
  private readonly injector = inject(Injector);
  private readonly detail = viewChild<ElementRef<HTMLElement>>('orderDetail');
  private readonly ordersService = inject(OrdersService);
  private readonly refresh = new Subject<void>();
  private readonly selectedId = signal<number | null>(null);

  readonly minTotal = signal(0);
  readonly state = toSignal(
    this.refresh.pipe(
      startWith(undefined),
      switchMap(() =>
        this.ordersService.getOrders().pipe(
          map((response): OrdersState => ({ status: 'success', response })),
          catchError(() => of<OrdersState>({ status: 'error' })),
          startWith<OrdersState>({ status: 'loading' }),
        ),
      ),
    ),
    { initialValue: { status: 'loading' } as OrdersState },
  );

  readonly orders = computed(() => {
    const state = this.state();
    return state.status === 'success' ? state.response.carts : [];
  });
  readonly filteredOrders = computed(() =>
    this.orders().filter((order) => order.total >= this.minTotal()),
  );
  readonly selectedOrder = computed<Order | undefined>(() =>
    this.filteredOrders().find((order) => order.id === this.selectedId()),
  );
  readonly displayedTotal = computed(() =>
    this.filteredOrders().reduce((total, order) => total + order.total, 0),
  );

  setMinTotal(value: string): void {
    const amount = Number(value);
    this.minTotal.set(Number.isFinite(amount) ? Math.max(0, amount) : 0);
  }

  retry(): void {
    this.closeDetail();
    this.refresh.next();
  }

  selectOrder(id: number): void {
    this.selectedId.set(id);
    afterNextRender(() => this.detail()?.nativeElement.focus(), { injector: this.injector });
  }

  closeDetail(): void {
    this.selectedId.set(null);
  }
}
