import React from 'react';
import { Link } from 'react-router-dom';

function Cart({ items, onUpdateQuantity, onRemove }) {
  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(price);
  };

  const calculateTotal = () => {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  };

  if (items.length === 0) {
    return (
      <div className="cart-container">
        <h2 className="cart-title">Shopping Cart</h2>
        <div className="cart-empty">
          <p>Your cart is empty.</p>
          <Link to="/" className="btn btn-primary" style={{ marginTop: '16px', display: 'inline-block' }}>
            Continue Shopping
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="cart-container">
      <h2 className="cart-title">Shopping Cart</h2>

      {items.map(item => (
        <div key={item.id} className="cart-item">
          <img
            src={item.imageUrl || `https://via.placeholder.com/80x80?text=${encodeURIComponent(item.name)}`}
            alt={item.name}
            className="cart-item-image"
          />
          <div className="cart-item-info">
            <p className="cart-item-name">{item.name}</p>
            <p className="cart-item-price">{formatPrice(item.price)} each</p>
          </div>
          <div className="cart-item-quantity">
            <button
              className="quantity-btn"
              onClick={() => onUpdateQuantity(item.id, item.quantity - 1)}
            >
              -
            </button>
            <span>{item.quantity}</span>
            <button
              className="quantity-btn"
              onClick={() => onUpdateQuantity(item.id, item.quantity + 1)}
            >
              +
            </button>
          </div>
          <span className="cart-item-total">
            {formatPrice(item.price * item.quantity)}
          </span>
          <button
            className="btn btn-secondary"
            onClick={() => onRemove(item.id)}
            style={{ marginLeft: '16px' }}
          >
            Remove
          </button>
        </div>
      ))}

      <div className="cart-summary">
        <div className="cart-total">
          <span>Total:</span>
          <span>{formatPrice(calculateTotal())}</span>
        </div>
        <Link to="/checkout" className="btn btn-primary btn-full-width">
          Proceed to Checkout
        </Link>
      </div>
    </div>
  );
}

export default Cart;
