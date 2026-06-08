import React, { useState, useEffect } from 'react';
import { Routes, Route } from 'react-router-dom';
import Header from './components/Header';
import ProductList from './components/ProductList';
import Cart from './components/Cart';
import Checkout from './components/Checkout';
import OrderStatus from './components/OrderStatus';
import { getProducts } from './services/api';

function App() {
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadProducts();
  }, []);

  const loadProducts = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getProducts();
      setProducts(data);
    } catch (err) {
      setError('Failed to load products. Please try again.');
      console.error('Error loading products:', err);
    } finally {
      setLoading(false);
    }
  };

  const addToCart = (product) => {
    setCart(prevCart => {
      const existing = prevCart.find(item => item.id === product.id);
      if (existing) {
        return prevCart.map(item =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      }
      return [...prevCart, { ...product, quantity: 1 }];
    });
  };

  const removeFromCart = (productId) => {
    setCart(prevCart => prevCart.filter(item => item.id !== productId));
  };

  const updateQuantity = (productId, quantity) => {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    setCart(prevCart =>
      prevCart.map(item =>
        item.id === productId ? { ...item, quantity } : item
      )
    );
  };

  const clearCart = () => {
    setCart([]);
  };

  const cartItemCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <div className="app">
      <Header cartItemCount={cartItemCount} />
      <main className="main-content">
        <Routes>
          <Route
            path="/"
            element={
              <ProductList
                products={products}
                loading={loading}
                error={error}
                onAddToCart={addToCart}
                onRetry={loadProducts}
              />
            }
          />
          <Route
            path="/cart"
            element={
              <Cart
                items={cart}
                onUpdateQuantity={updateQuantity}
                onRemove={removeFromCart}
              />
            }
          />
          <Route
            path="/checkout"
            element={
              <Checkout
                items={cart}
                onOrderComplete={clearCart}
              />
            }
          />
          <Route
            path="/order/:orderId"
            element={<OrderStatus />}
          />
        </Routes>
      </main>
    </div>
  );
}

export default App;
