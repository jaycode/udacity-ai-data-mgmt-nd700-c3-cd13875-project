#!/bin/bash
#
# Seed DynamoDB tables with sample data
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

AWS_REGION="${AWS_REGION:-us-east-1}"
STACK_PREFIX="shopfast"
ENVIRONMENT="${ENVIRONMENT:-dev}"

echo -e "${GREEN}Seeding Sample Data${NC}"
echo ""

PRODUCTS_TABLE="${STACK_PREFIX}-products-${ENVIRONMENT}"
INVENTORY_TABLE="${STACK_PREFIX}-inventory-${ENVIRONMENT}"
ORDERS_TABLE="${STACK_PREFIX}-orders-${ENVIRONMENT}"

# Check if tables exist
echo -e "${YELLOW}Checking DynamoDB tables...${NC}"
aws dynamodb describe-table --table-name "${PRODUCTS_TABLE}" --region "${AWS_REGION}" > /dev/null 2>&1 || {
    echo "Products table not found. Make sure the data stack is deployed."
    exit 1
}

# Seed Products
echo -e "${YELLOW}Seeding products...${NC}"
PRODUCTS='[
  {"productId": {"S": "prod-001"}, "name": {"S": "Wireless Bluetooth Headphones"}, "price": {"N": "79.99"}, "category": {"S": "Electronics"}, "description": {"S": "High-quality wireless headphones with noise cancellation"}},
  {"productId": {"S": "prod-002"}, "name": {"S": "USB-C Charging Cable"}, "price": {"N": "14.99"}, "category": {"S": "Electronics"}, "description": {"S": "Fast charging USB-C cable, 6ft length"}},
  {"productId": {"S": "prod-003"}, "name": {"S": "Laptop Stand"}, "price": {"N": "39.99"}, "category": {"S": "Office"}, "description": {"S": "Adjustable aluminum laptop stand"}},
  {"productId": {"S": "prod-004"}, "name": {"S": "Mechanical Keyboard"}, "price": {"N": "129.99"}, "category": {"S": "Electronics"}, "description": {"S": "RGB mechanical keyboard with Cherry MX switches"}},
  {"productId": {"S": "prod-005"}, "name": {"S": "Ergonomic Mouse"}, "price": {"N": "49.99"}, "category": {"S": "Electronics"}, "description": {"S": "Wireless ergonomic mouse with side buttons"}},
  {"productId": {"S": "prod-006"}, "name": {"S": "Monitor Light Bar"}, "price": {"N": "59.99"}, "category": {"S": "Office"}, "description": {"S": "LED light bar for monitor, adjustable brightness"}},
  {"productId": {"S": "prod-007"}, "name": {"S": "Webcam HD 1080p"}, "price": {"N": "69.99"}, "category": {"S": "Electronics"}, "description": {"S": "Full HD webcam with built-in microphone"}},
  {"productId": {"S": "prod-008"}, "name": {"S": "Desk Organizer"}, "price": {"N": "24.99"}, "category": {"S": "Office"}, "description": {"S": "Bamboo desk organizer with drawers"}},
  {"productId": {"S": "prod-009"}, "name": {"S": "Wireless Charger Pad"}, "price": {"N": "29.99"}, "category": {"S": "Electronics"}, "description": {"S": "Fast wireless charging pad, Qi compatible"}},
  {"productId": {"S": "prod-010"}, "name": {"S": "Standing Desk Mat"}, "price": {"N": "44.99"}, "category": {"S": "Office"}, "description": {"S": "Anti-fatigue standing desk mat"}}
]'

echo "${PRODUCTS}" | jq -c '.[]' | while read item; do
    aws dynamodb put-item \
        --table-name "${PRODUCTS_TABLE}" \
        --item "${item}" \
        --region "${AWS_REGION}" 2>/dev/null || true
done

echo "Products seeded: 10 items"

# Seed Inventory
echo -e "${YELLOW}Seeding inventory...${NC}"
INVENTORY='[
  {"productId": {"S": "prod-001"}, "quantity": {"N": "100"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-002"}, "quantity": {"N": "500"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-003"}, "quantity": {"N": "75"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-004"}, "quantity": {"N": "50"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-005"}, "quantity": {"N": "200"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-006"}, "quantity": {"N": "80"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-007"}, "quantity": {"N": "120"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-008"}, "quantity": {"N": "150"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-009"}, "quantity": {"N": "300"}, "reserved": {"N": "0"}},
  {"productId": {"S": "prod-010"}, "quantity": {"N": "60"}, "reserved": {"N": "0"}}
]'

echo "${INVENTORY}" | jq -c '.[]' | while read item; do
    aws dynamodb put-item \
        --table-name "${INVENTORY_TABLE}" \
        --item "${item}" \
        --region "${AWS_REGION}" 2>/dev/null || true
done

echo "Inventory seeded: 10 items"

# Seed sample orders
echo -e "${YELLOW}Seeding sample orders...${NC}"
ORDERS='[
  {"orderId": {"S": "order-001"}, "userId": {"S": "user-123"}, "items": {"L": [{"M": {"productId": {"S": "prod-001"}, "quantity": {"N": "1"}, "price": {"N": "79.99"}}}]}, "status": {"S": "DELIVERED"}, "total": {"N": "79.99"}, "createdAt": {"S": "2024-01-15T10:30:00Z"}},
  {"orderId": {"S": "order-002"}, "userId": {"S": "user-123"}, "items": {"L": [{"M": {"productId": {"S": "prod-003"}, "quantity": {"N": "2"}, "price": {"N": "39.99"}}}]}, "status": {"S": "SHIPPED"}, "total": {"N": "79.98"}, "createdAt": {"S": "2024-01-16T14:20:00Z"}},
  {"orderId": {"S": "order-003"}, "userId": {"S": "user-456"}, "items": {"L": [{"M": {"productId": {"S": "prod-004"}, "quantity": {"N": "1"}, "price": {"N": "129.99"}}}, {"M": {"productId": {"S": "prod-005"}, "quantity": {"N": "1"}, "price": {"N": "49.99"}}}]}, "status": {"S": "PENDING"}, "total": {"N": "179.98"}, "createdAt": {"S": "2024-01-17T09:15:00Z"}}
]'

echo "${ORDERS}" | jq -c '.[]' | while read item; do
    aws dynamodb put-item \
        --table-name "${ORDERS_TABLE}" \
        --item "${item}" \
        --region "${AWS_REGION}" 2>/dev/null || true
done

echo "Orders seeded: 3 items"

echo ""
echo -e "${GREEN}Sample data seeding complete${NC}"

echo ""
echo "Summary:"
echo "  - Products: 10 items in ${PRODUCTS_TABLE}"
echo "  - Inventory: 10 items in ${INVENTORY_TABLE}"
echo "  - Orders: 3 items in ${ORDERS_TABLE}"
