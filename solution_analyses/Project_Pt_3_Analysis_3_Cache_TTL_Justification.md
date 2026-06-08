# Cache TTL Justification

The product cache TTL is 300 seconds.

Five minutes is a practical default for catalog data because product names, categories, and descriptions do not usually change second by second. It is short enough that price or inventory-adjacent corrections propagate quickly, but long enough to absorb repeated product detail views during normal browsing.

This TTL also limits stale data risk. If ShopFast later adds product update events, those events can invalidate the `product:{productId}` key immediately while keeping the same TTL as a fallback.
