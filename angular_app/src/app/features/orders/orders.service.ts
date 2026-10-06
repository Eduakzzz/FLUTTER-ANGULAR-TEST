import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { OrdersResponse } from './order.model';

// root registra el servicio en el inyector de la aplicación.
@Injectable({ providedIn: 'root' })
export class OrdersService {
  // inject obtiene la dependencia; private limita su acceso a la clase.
  private readonly http = inject(HttpClient);
  private readonly endpoint = 'https://dummyjson.com/carts';

  // <OrdersResponse> indica el tipo emitido por el Observable.
  getOrders(): Observable<OrdersResponse> {
    // limit=0 obtiene todos los pedidos para el filtro local.
    return this.http.get<OrdersResponse>(this.endpoint, { params: { limit: 0 } });
  }
}
