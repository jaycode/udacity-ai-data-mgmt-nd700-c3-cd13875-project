import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { createOrder } from '../services/api';

function Checkout({ items, onOrderComplete }) {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({
    email: '',
    firstName: '',
    lastName: '',
    address: '',
    city: '',
    state: '',
    zipCode: '',
    cardNumber: '',
    expiryDate: '',
    cvv: ''
  });

  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(price);
  };

  const calculateTotal = () => {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const orderData = {
        items: items.map(item => ({
          productId: item.id,
          quantity: item.quantity,
          price: item.price
        })),
        customer: {
          email: formData.email,
          firstName: formData.firstName,
          lastName: formData.lastName
        },
        shippingAddress: {
          address: formData.address,
          city: formData.city,
          state: formData.state,
          zipCode: formData.zipCode
        },
        total: calculateTotal()
      };

      const result = await createOrder(orderData);
      onOrderComplete();
      navigate(`/order/${result.orderId}`);
    } catch (err) {
      setError('Failed to place order. Please try again.');
      console.error('Order error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (items.length === 0) {
    return (
      <div className="cart-container">
        <h2 className="cart-title">Checkout</h2>
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
    <div className="checkout-container">
      <form className="checkout-form" onSubmit={handleSubmit}>
        <h2 className="cart-title">Checkout</h2>

        {error && <p className="error-message">{error}</p>}

        <h3 style={{ marginBottom: '16px' }}>Contact Information</h3>
        <div className="form-group">
          <label className="form-label">Email</label>
          <input
            type="email"
            name="email"
            className="form-input"
            value={formData.email}
            onChange={handleChange}
            required
          />
        </div>

        <div className="form-row">
          <div className="form-group">
            <label className="form-label">First Name</label>
            <input
              type="text"
              name="firstName"
              className="form-input"
              value={formData.firstName}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label className="form-label">Last Name</label>
            <input
              type="text"
              name="lastName"
              className="form-input"
              value={formData.lastName}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <h3 style={{ marginBottom: '16px', marginTop: '24px' }}>Shipping Address</h3>
        <div className="form-group">
          <label className="form-label">Address</label>
          <input
            type="text"
            name="address"
            className="form-input"
            value={formData.address}
            onChange={handleChange}
            required
          />
        </div>

        <div className="form-row">
          <div className="form-group">
            <label className="form-label">City</label>
            <input
              type="text"
              name="city"
              className="form-input"
              value={formData.city}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label className="form-label">State</label>
            <input
              type="text"
              name="state"
              className="form-input"
              value={formData.state}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label">ZIP Code</label>
          <input
            type="text"
            name="zipCode"
            className="form-input"
            value={formData.zipCode}
            onChange={handleChange}
            required
            style={{ maxWidth: '200px' }}
          />
        </div>

        <h3 style={{ marginBottom: '16px', marginTop: '24px' }}>Payment Information</h3>
        <div className="form-group">
          <label className="form-label">Card Number</label>
          <input
            type="text"
            name="cardNumber"
            className="form-input"
            placeholder="1234 5678 9012 3456"
            value={formData.cardNumber}
            onChange={handleChange}
            required
          />
        </div>

        <div className="form-row">
          <div className="form-group">
            <label className="form-label">Expiry Date</label>
            <input
              type="text"
              name="expiryDate"
              className="form-input"
              placeholder="MM/YY"
              value={formData.expiryDate}
              onChange={handleChange}
              required
            />
          </div>
          <div className="form-group">
            <label className="form-label">CVV</label>
            <input
              type="text"
              name="cvv"
              className="form-input"
              placeholder="123"
              value={formData.cvv}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <button
          type="submit"
          className="btn btn-primary btn-full-width"
          disabled={loading}
          style={{ marginTop: '24px' }}
        >
          {loading ? 'Placing Order...' : `Place Order - ${formatPrice(calculateTotal())}`}
        </button>
      </form>

      <div className="cart-container">
        <h3 style={{ marginBottom: '16px' }}>Order Summary</h3>
        {items.map(item => (
          <div key={item.id} className="cart-item" style={{ padding: '12px 0' }}>
            <div className="cart-item-info">
              <p className="cart-item-name">{item.name}</p>
              <p className="cart-item-price">Qty: {item.quantity}</p>
            </div>
            <span className="cart-item-total">
              {formatPrice(item.price * item.quantity)}
            </span>
          </div>
        ))}
        <div className="cart-summary" style={{ marginTop: '16px', paddingTop: '16px' }}>
          <div className="cart-total">
            <span>Total:</span>
            <span>{formatPrice(calculateTotal())}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Checkout;
