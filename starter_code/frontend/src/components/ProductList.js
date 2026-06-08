import React from 'react';
import ProductCard from './ProductCard';

function ProductList({ products, loading, error, onAddToCart, onRetry }) {
  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading products...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="error-container">
        <p className="error-message">{error}</p>
        <button className="btn btn-primary" onClick={onRetry}>
          Try Again
        </button>
      </div>
    );
  }

  if (products.length === 0) {
    return (
      <div className="loading-container">
        <p>No products available.</p>
      </div>
    );
  }

  return (
    <div className="product-list">
      {products.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onAddToCart={onAddToCart}
        />
      ))}
    </div>
  );
}

export default ProductList;
