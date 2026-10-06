import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { OrdersResponse } from './order.model';

@Injectable({ providedIn: 'root' })
export class OrdersService {
  private readonly http = inject(HttpClient);
  private readonly endpoint = 'https://dummyjson.com/carts';

  getOrders(): Observable<OrdersResponse> {
    return this.http.get<OrdersResponse>(this.endpoint, { params: { limit: 0 } });
  }
}
