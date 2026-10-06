import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Order, OrdersResponse } from './order.model';
import { OrdersPageComponent } from './orders-page.component';

const order: Order = {
  id: 1,
  userId: 142,
  total: 100,
  discountedTotal: 90,
  totalProducts: 1,
  totalQuantity: 2,
  products: [
    {
      id: 144,
      title: 'Cricket Helmet',
      price: 50,
      quantity: 2,
      total: 100,
      discountPercentage: 10,
      discountedTotal: 90,
      thumbnail: 'https://example.test/helmet.png',
    },
  ],
};
const ordersResponse: OrdersResponse = {
  carts: [order, { ...order, id: 2, total: 200, discountedTotal: 180 }],
  total: 2,
  skip: 0,
  limit: 2,
};

describe('OrdersPageComponent', () => {
  let fixture: ComponentFixture<OrdersPageComponent>;
  let http: HttpTestingController;
  let element: HTMLElement;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [OrdersPageComponent],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    fixture = TestBed.createComponent(OrdersPageComponent);
    http = TestBed.inject(HttpTestingController);
    element = fixture.nativeElement as HTMLElement;
    fixture.detectChanges();
  });

  afterEach(() => http.verify());

  function loadOrders(response: OrdersResponse = ordersResponse): void {
    http.expectOne('https://dummyjson.com/carts?limit=0').flush(response);
    fixture.detectChanges();
  }

  it('renders loading and then filters locally, including the minimum boundary', () => {
    expect(element.textContent).toContain('Cargando pedidos');
    loadOrders();
    expect(element.querySelectorAll('app-order-card')).toHaveLength(2);
    const input = element.querySelector<HTMLInputElement>('#min-total')!;
    input.value = '200';
    input.dispatchEvent(new Event('input'));
    fixture.detectChanges();
    expect(element.querySelectorAll('app-order-card')).toHaveLength(1);
    expect(fixture.componentInstance.displayedTotal()).toBe(200);
    http.expectNone('https://dummyjson.com/carts?limit=0');
  });

  it('renders an HTTP error and recovers through the retry button', () => {
    http.expectOne('https://dummyjson.com/carts?limit=0').flush('Unavailable', {
      status: 503,
      statusText: 'Service Unavailable',
    });
    fixture.detectChanges();
    expect(element.querySelector('[role="alert"]')?.textContent).toContain('No pudimos cargar');
    element.querySelector<HTMLButtonElement>('[role="alert"] button')!.click();
    fixture.detectChanges();
    expect(element.textContent).toContain('Cargando pedidos');
    loadOrders();
    expect(element.querySelectorAll('app-order-card')).toHaveLength(2);
  });

  it('handles an empty response and an empty filter result separately', () => {
    loadOrders({ carts: [], total: 0, skip: 0, limit: 0 });
    expect(element.textContent).toContain('Todavía no hay pedidos');
    fixture.componentInstance.retry();
    loadOrders();
    fixture.componentInstance.setMinTotal('201');
    fixture.detectChanges();
    expect(element.textContent).toContain('Sin resultados para este filtro');
    fixture.componentInstance.setMinTotal('0');
    fixture.detectChanges();
    expect(element.querySelectorAll('app-order-card')).toHaveLength(2);
  });

  it('opens detail from the card output and hides it when its order is filtered out', () => {
    loadOrders();
    element.querySelector<HTMLButtonElement>('app-order-card button')!.click();
    fixture.detectChanges();
    expect(element.querySelector('#order-detail')?.textContent).toContain('Cricket Helmet');
    expect(element.querySelector('app-order-card button')?.getAttribute('aria-expanded')).toBe(
      'true',
    );
    fixture.componentInstance.setMinTotal('150');
    fixture.detectChanges();
    expect(element.querySelector('#order-detail')).toBeNull();
  });

  it('cancels an outstanding HTTP request when the component is destroyed', () => {
    const request = http.expectOne('https://dummyjson.com/carts?limit=0');
    fixture.destroy();
    expect(request.cancelled).toBe(true);
  });
});
