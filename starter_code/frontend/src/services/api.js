import axios from 'axios';

// API Gateway endpoint - will be set by environment variable or bootstrap
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('[API] Request error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      console.error(`[API] Error ${error.response.status}:`, error.response.data);
    } else if (error.request) {
      console.error('[API] No response received:', error.request);
    } else {
      console.error('[API] Error:', error.message);
    }
    return Promise.reject(error);
  }
);

// Product Service APIs
export const getProducts = async () => {
  const response = await api.get('/products');
  return response.data;
};

export const getProduct = async (productId) => {
  const response = await api.get(`/products/${productId}`);
  return response.data;
};

// Order Service APIs
export const createOrder = async (orderData) => {
  const response = await api.post('/orders', orderData);
  return response.data;
};

export const getOrderStatus = async (orderId) => {
  const response = await api.get(`/orders/${orderId}`);
  return response.data;
};

export const getUserOrders = async () => {
  const response = await api.get('/orders');
  return response.data;
};

// Inventory Service APIs
export const checkInventory = async (productId) => {
  const response = await api.get(`/inventory/${productId}`);
  return response.data;
};

export default api;
