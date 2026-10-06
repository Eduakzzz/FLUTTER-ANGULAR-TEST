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

// | indica alternativas; success incluye la respuesta.
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
  // <...> especifica tipos; viewChild encuentra el panel del template.
  private readonly detail = viewChild<ElementRef<HTMLElement>>('orderDetail');
  private readonly ordersService = inject(OrdersService);
  // Subject emite eventos; void indica que no llevan datos.
  private readonly refresh = new Subject<void>();
  // Signal guarda el ID actual; null representa ninguna selección.
  private readonly selectedId = signal<number | null>(null);

  readonly minTotal = signal(0);
  // toSignal conecta el Observable y limpia la suscripción al destruirse.
  readonly state = toSignal(
    this.refresh.pipe(
      startWith(undefined), // Solicita la carga inicial.
      // Sustituye la petición anterior al actualizar.
      switchMap(() =>
        this.ordersService.getOrders().pipe(
          map((response): OrdersState => ({ status: 'success', response })),
          // Recupera esta petición y conserva futuros reintentos.
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
  // => define una función; computed observa los Signals que lee.
  readonly filteredOrders = computed(() =>
    this.orders().filter((order) => order.total >= this.minTotal()),
  );
  // undefined indica que no hay un pedido visible con ese ID.
  readonly selectedOrder = computed<Order | undefined>(() =>
    this.filteredOrders().find((order) => order.id === this.selectedId()),
  );
  readonly displayedTotal = computed(() =>
    this.filteredOrders().reduce((total, order) => total + order.total, 0),
  );

  setMinTotal(value: string): void {
    // Normaliza el texto del input a un mínimo válido.
    const amount = Number(value);
    this.minTotal.set(Number.isFinite(amount) ? Math.max(0, amount) : 0);
  }

  retry(): void {
    this.closeDetail();
    this.refresh.next(); // Emite el evento que inicia otra carga.
  }

  selectOrder(id: number): void {
    this.selectedId.set(id);
    // ?. enfoca sólo si existe el panel tras renderizarlo.
    afterNextRender(() => this.detail()?.nativeElement.focus(), { injector: this.injector });
  }

  closeDetail(): void {
    this.selectedId.set(null);
  }
}
