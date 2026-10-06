import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { OrdersResponse } from './order.model';
import { OrdersService } from './orders.service';

describe('OrdersService', () => {
  let service: OrdersService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      // Sustituye la red por peticiones controladas desde la prueba.
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(OrdersService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('requests every cart and preserves the typed response', () => {
    const response: OrdersResponse = { carts: [], total: 0, skip: 0, limit: 0 };
    let received: OrdersResponse | undefined;
    service.getOrders().subscribe((orders) => (received = orders));

    const request = http.expectOne('https://dummyjson.com/carts?limit=0');
    expect(request.request.method).toBe('GET');
    request.flush(response);
    expect(received).toEqual(response);
  });

  it('propagates an HTTP failure to its consumer', () => {
    let status: number | undefined;
    service
      .getOrders()
      .subscribe({ error: (error: { status: number }) => (status = error.status) });
    http.expectOne('https://dummyjson.com/carts?limit=0').flush('Unavailable', {
      status: 503,
      statusText: 'Service Unavailable',
    });
    expect(status).toBe(503);
  });
});
