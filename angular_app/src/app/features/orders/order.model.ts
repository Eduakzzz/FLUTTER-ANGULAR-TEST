// interface describe datos; readonly protege asignaciones al compilar.
export interface OrderProduct {
  readonly id: number;
  readonly title: string;
  readonly price: number;
  readonly quantity: number;
  readonly total: number;
  readonly discountPercentage: number;
  readonly discountedTotal: number;
  readonly thumbnail: string;
}

export interface Order {
  readonly id: number;
  readonly products: readonly OrderProduct[];
  readonly total: number;
  readonly discountedTotal: number;
  readonly userId: number;
  readonly totalProducts: number;
  readonly totalQuantity: number;
}

// Tipos de la respuesta; no validan JSON durante la ejecución.
export interface OrdersResponse {
  readonly carts: readonly Order[];
  readonly total: number;
  readonly skip: number;
  readonly limit: number;
}
