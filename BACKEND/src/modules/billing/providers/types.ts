// Forma normalizada de una compra, independiente de la tienda.
export interface NormalizedPurchase {
  productId: string;
  transactionId: string;
  expiresAt: Date | null;
  autoRenew: boolean;
  active: boolean;
  raw: unknown;
  originalTransactionId?: string; // Apple
  purchaseToken?: string; // Google
}
