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

export interface OrdersResponse {
  readonly carts: readonly Order[];
  readonly total: number;
  readonly skip: number;
  readonly limit: number;
}
