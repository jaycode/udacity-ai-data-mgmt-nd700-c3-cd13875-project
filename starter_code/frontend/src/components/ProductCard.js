import React from 'react';

function ProductCard({ product, onAddToCart }) {
  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(price);
  };

  return (
    <div className="product-card">
      <img
        src={product.imageUrl || `https://via.placeholder.com/300x200?text=${encodeURIComponent(product.name)}`}
        alt={product.name}
        className="product-image"
      />
      <div className="product-info">
        <h3 className="product-name">{product.name}</h3>
        <p className="product-description">{product.description}</p>
        <p className="product-price">{formatPrice(product.price)}</p>
        <button
          className="btn btn-primary btn-full-width"
          onClick={() => onAddToCart(product)}
        >
          Add to Cart
        </button>
      </div>
    </div>
  );
}

export default ProductCard;
