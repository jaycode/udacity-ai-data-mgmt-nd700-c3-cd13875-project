#!/bin/bash
#
# Build and Deploy React Frontend to S3/CloudFront
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STARTER_CODE="${PROJECT_ROOT}/../starter_code"
AWS_REGION="${AWS_REGION:-us-east-1}"
STACK_PREFIX="shopfast"
ENVIRONMENT="${ENVIRONMENT:-dev}"

echo -e "${GREEN}Deploying React Frontend${NC}"
echo ""

# Get S3 bucket and CloudFront distribution from CloudFormation
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_PREFIX}-frontend" \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

CLOUDFRONT_ID=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_PREFIX}-frontend" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

API_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_PREFIX}-lambda" \
    --query 'Stacks[0].Outputs[?OutputKey==`ProductServiceApiUrl`].OutputValue' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

if [ -z "${BUCKET_NAME}" ] || [ "${BUCKET_NAME}" == "None" ]; then
    echo -e "${YELLOW}Frontend stack not deployed yet, skipping frontend deployment${NC}"
    exit 0
fi

echo "S3 Bucket: ${BUCKET_NAME}"
echo "CloudFront Distribution: ${CLOUDFRONT_ID}"
echo "Product API URL: ${API_URL:-not available}"
echo ""

# Check if starter code exists
if [ -d "${STARTER_CODE}/frontend" ]; then
    echo "Building from starter code..."
    cd "${STARTER_CODE}/frontend"
else
    echo -e "${YELLOW}Creating temporary React application${NC}"
    TEMP_DIR=$(mktemp -d)
    cd "${TEMP_DIR}"

    # Create React app with create-react-app
    npx create-react-app shopfast-frontend --template typescript 2>/dev/null || \
    npx create-react-app shopfast-frontend

    cd shopfast-frontend

    # Create basic components
    mkdir -p src/components src/services

    # API service - uses static demo data since Lambda is invoked via AWS SDK, not HTTP
    cat > src/services/api.js << 'EOF'
// Static demo data - Lambda functions are invoked via AWS SDK, not HTTP endpoints
// In production, you would use AWS SDK to invoke Lambda directly or set up API Gateway
const DEMO_PRODUCTS = [
  { productId: 'PROD-001', name: 'Wireless Headphones', price: '79.99', category: 'Electronics' },
  { productId: 'PROD-002', name: 'Smart Watch', price: '199.99', category: 'Electronics' },
  { productId: 'PROD-003', name: 'Laptop Stand', price: '49.99', category: 'Office' },
  { productId: 'PROD-004', name: 'USB-C Hub', price: '39.99', category: 'Electronics' },
  { productId: 'PROD-005', name: 'Mechanical Keyboard', price: '129.99', category: 'Electronics' },
];

export const api = {
  async getProducts() {
    // Simulate network delay for demo purposes
    await new Promise(resolve => setTimeout(resolve, 500));
    return DEMO_PRODUCTS;
  },

  async getProduct(productId) {
    await new Promise(resolve => setTimeout(resolve, 300));
    const product = DEMO_PRODUCTS.find(p => p.productId === productId);
    if (!product) throw new Error('Product not found');
    return product;
  },

  async createOrder(order) {
    await new Promise(resolve => setTimeout(resolve, 500));
    // Simulate order creation
    return { orderId: `ORD-${Date.now()}`, status: 'created', ...order };
  },

  async getOrders(userId) {
    await new Promise(resolve => setTimeout(resolve, 300));
    // Return demo orders
    return [
      { orderId: 'ORD-DEMO-001', userId, status: 'delivered', total: '79.99' },
    ];
  },

  async getInventory(productId) {
    await new Promise(resolve => setTimeout(resolve, 200));
    return { productId, quantity: Math.floor(Math.random() * 100) + 10 };
  },
};

export default api;
EOF

    # Update App.js
    cat > src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import './App.css';
import api from './services/api';

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
      const data = await api.getProducts();
      setProducts(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const addToCart = (product) => {
    setCart([...cart, { ...product, quantity: 1 }]);
  };

  const checkout = async () => {
    try {
      const order = {
        userId: 'user-123',
        items: cart.map(item => ({
          productId: item.productId,
          quantity: item.quantity,
          price: parseFloat(item.price),
        })),
      };
      await api.createOrder(order);
      setCart([]);
      alert('Order placed successfully!');
    } catch (err) {
      setError(err.message);
    }
  };

  if (loading) return <div className="loading">Loading products...</div>;
  if (error) return <div className="error">Error: {error}</div>;

  return (
    <div className="App">
      <header className="App-header">
        <h1>ShopFast</h1>
        <div className="cart-icon">Cart ({cart.length})</div>
      </header>

      <main>
        <section className="products">
          <h2>Products</h2>
          <div className="product-grid">
            {products.map(product => (
              <div key={product.productId} className="product-card">
                <h3>{product.name}</h3>
                <p className="price">${product.price}</p>
                <p className="category">{product.category}</p>
                <button onClick={() => addToCart(product)}>Add to Cart</button>
              </div>
            ))}
          </div>
        </section>

        {cart.length > 0 && (
          <section className="cart">
            <h2>Shopping Cart</h2>
            {cart.map((item, index) => (
              <div key={index} className="cart-item">
                <span>{item.name}</span>
                <span>${item.price}</span>
              </div>
            ))}
            <div className="cart-total">
              Total: ${cart.reduce((sum, item) => sum + parseFloat(item.price), 0).toFixed(2)}
            </div>
            <button onClick={checkout} className="checkout-btn">Checkout</button>
          </section>
        )}
      </main>
    </div>
  );
}

export default App;
EOF

    # Update App.css
    cat > src/App.css << 'EOF'
.App {
  font-family: Arial, sans-serif;
}

.App-header {
  background-color: #232f3e;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cart-icon {
  background-color: #ff9900;
  padding: 0.5rem 1rem;
  border-radius: 4px;
}

main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1.5rem;
}

.product-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
}

.product-card h3 {
  margin: 0 0 0.5rem 0;
}

.price {
  font-size: 1.25rem;
  font-weight: bold;
  color: #b12704;
}

.category {
  color: #666;
  font-size: 0.875rem;
}

.product-card button {
  background-color: #ff9900;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  margin-top: 1rem;
}

.product-card button:hover {
  background-color: #e88a00;
}

.cart {
  margin-top: 2rem;
  padding: 1rem;
  background-color: #f5f5f5;
  border-radius: 8px;
}

.cart-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid #ddd;
}

.cart-total {
  font-size: 1.25rem;
  font-weight: bold;
  text-align: right;
  margin-top: 1rem;
}

.checkout-btn {
  display: block;
  width: 100%;
  margin-top: 1rem;
  padding: 1rem;
  background-color: #ff9900;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
}

.loading, .error {
  text-align: center;
  padding: 2rem;
  font-size: 1.25rem;
}

.error {
  color: #b12704;
}
EOF

fi

# Build React app
echo -e "${YELLOW}Building React application...${NC}"
npm install
if [ -n "${API_URL}" ] && [ "${API_URL}" != "None" ]; then
    REACT_APP_API_URL="${API_URL}" npm run build
else
    npm run build
fi

# Upload to S3
echo -e "${YELLOW}Uploading to S3...${NC}"
aws s3 sync build/ "s3://${BUCKET_NAME}/" --delete

# Invalidate CloudFront cache
if [ -n "${CLOUDFRONT_ID}" ] && [ "${CLOUDFRONT_ID}" != "None" ]; then
    echo -e "${YELLOW}Invalidating CloudFront cache...${NC}"
    aws cloudfront create-invalidation \
        --distribution-id "${CLOUDFRONT_ID}" \
        --paths "/*" 2>/dev/null || echo "CloudFront invalidation pending"
fi

# Cleanup temp directory if used
if [ -n "${TEMP_DIR}" ]; then
    rm -rf "${TEMP_DIR}"
fi

# Get CloudFront URL
CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_PREFIX}-frontend" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontUrl`].OutputValue' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

echo ""
echo -e "${GREEN}Frontend deployed successfully${NC}"
echo ""
echo "Frontend URL: ${CLOUDFRONT_URL}"
