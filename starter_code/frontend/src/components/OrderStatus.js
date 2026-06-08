import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getOrderStatus } from '../services/api';

function OrderStatus() {
  const { orderId } = useParams();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadOrderStatus();
    // Poll for updates every 10 seconds
    const interval = setInterval(loadOrderStatus, 10000);
    return () => clearInterval(interval);
  }, [orderId]);

  const loadOrderStatus = async () => {
    try {
      const data = await getOrderStatus(orderId);
      setOrder(data);
      setError(null);
    } catch (err) {
      setError('Failed to load order status.');
      console.error('Error loading order:', err);
    } finally {
      setLoading(false);
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'confirmed':
        return '✓';
      case 'processing':
        return '⚙';
      case 'shipped':
        return '📦';
      case 'delivered':
        return '🎉';
      default:
        return '⏳';
    }
  };

  const getStatusTitle = (status) => {
    switch (status) {
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Processing Your Order';
      case 'shipped':
        return 'Order Shipped';
      case 'delivered':
        return 'Order Delivered';
      default:
        return 'Order Placed';
    }
  };

  const timelineSteps = [
    { key: 'placed', label: 'Order Placed' },
    { key: 'confirmed', label: 'Order Confirmed' },
    { key: 'processing', label: 'Processing' },
    { key: 'shipped', label: 'Shipped' },
    { key: 'delivered', label: 'Delivered' }
  ];

  const getStepStatus = (stepKey, currentStatus) => {
    const statusOrder = ['placed', 'confirmed', 'processing', 'shipped', 'delivered'];
    const currentIndex = statusOrder.indexOf(currentStatus);
    const stepIndex = statusOrder.indexOf(stepKey);

    if (stepIndex < currentIndex) return 'completed';
    if (stepIndex === currentIndex) return 'current';
    return 'pending';
  };

  if (loading) {
    return (
      <div className="order-status-container">
        <div className="loading-spinner"></div>
        <p>Loading order status...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="order-status-container">
        <p className="error-message">{error}</p>
        <button className="btn btn-primary" onClick={loadOrderStatus}>
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="order-status-container">
      <div className="order-status-icon">
        {getStatusIcon(order?.status)}
      </div>
      <h1 className="order-status-title">
        {getStatusTitle(order?.status)}
      </h1>
      <p className="order-status-id">
        Order ID: {orderId}
      </p>

      <div className="order-status-timeline">
        {timelineSteps.map((step, index) => {
          const stepStatus = getStepStatus(step.key, order?.status || 'placed');
          return (
            <div key={step.key} className="timeline-item">
              <div className={`timeline-dot ${stepStatus}`}></div>
              <div className="timeline-content">
                <p className="timeline-title">{step.label}</p>
                {stepStatus === 'completed' && (
                  <p className="timeline-time">Completed</p>
                )}
                {stepStatus === 'current' && (
                  <p className="timeline-time">In progress...</p>
                )}
              </div>
            </div>
          );
        })}
      </div>

      <Link to="/" className="btn btn-primary">
        Continue Shopping
      </Link>
    </div>
  );
}

export default OrderStatus;
