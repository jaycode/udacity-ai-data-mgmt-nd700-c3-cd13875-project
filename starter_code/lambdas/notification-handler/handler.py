"""
Notification Handler Lambda

This Lambda function processes SNS notifications for order events
and sends customer notifications (email, SMS, etc.).
"""

import json
import os
import boto3

# Initialize AWS clients
ses = boto3.client('ses')
sns = boto3.client('sns')

FROM_EMAIL = os.environ.get('FROM_EMAIL', 'noreply@shopfast.example.com')


def lambda_handler(event, context):
    """
    Main Lambda handler for processing SNS notifications.

    Expected SNS message format:
    {
        "orderId": "order-123",
        "status": "confirmed",
        "customer": {
            "email": "customer@example.com",
            "firstName": "John"
        },
        "total": 99.99
    }

    """
    print(f"Received event: {json.dumps(event)}")

    processed = 0
    errors = 0

    for record in event.get('Records', []):
        try:
            # Parse SNS message
            sns_message = record.get('Sns', {})
            message_body = json.loads(sns_message.get('Message', '{}'))
            message_attributes = sns_message.get('MessageAttributes', {})

            # Log message attributes for debugging
            print(f"Message attributes: {json.dumps(message_attributes)}")

            # Get event type from message attributes
            event_type = get_attribute_value(message_attributes, 'eventType')

            if not event_type:
                # Fallback to inferring from message content
                event_type = infer_event_type(message_body)
                print(f"Inferred event type: {event_type}")

            # Process based on event type
            if event_type == 'order.created':
                send_order_confirmation(message_body)
            elif event_type == 'order.shipped':
                send_shipping_notification(message_body)
            elif event_type == 'order.delivered':
                send_delivery_notification(message_body)
            else:
                print(f"Unknown event type: {event_type}")

            processed += 1

        except Exception as e:
            print(f"Error processing record: {str(e)}")
            errors += 1

    result = {
        'processed': processed,
        'errors': errors
    }
    print(f"Processing complete: {json.dumps(result)}")

    return result


def get_attribute_value(attributes, key):
    """Extract value from SNS message attributes."""
    attr = attributes.get(key, {})
    return attr.get('Value') or attr.get('StringValue')


def infer_event_type(message):
    """Infer event type from message content."""
    status = message.get('status', '')
    if status == 'confirmed':
        return 'order.created'
    elif status == 'shipped':
        return 'order.shipped'
    elif status == 'delivered':
        return 'order.delivered'
    return 'unknown'


def send_order_confirmation(message):
    """Send order confirmation email to customer."""
    order_id = message.get('orderId', 'Unknown')
    customer = message.get('customer', {})
    email = customer.get('email')
    first_name = customer.get('firstName', 'Customer')
    total = message.get('total', 0)

    if not email:
        print(f"No email address for order {order_id}")
        return

    subject = f"Order Confirmation - {order_id}"
    body = f"""
    Hi {first_name},

    Thank you for your order!

    Order ID: {order_id}
    Total: ${total:.2f}

    We'll send you another email when your order ships.

    Thanks for shopping with ShopFast!
    """

    print(f"Sending order confirmation to {email}")
    # In production, this would actually send the email
    # For the course, we just log it
    print(f"Subject: {subject}")
    print(f"Body: {body}")


def send_shipping_notification(message):
    """Send shipping notification email to customer."""
    order_id = message.get('orderId', 'Unknown')
    customer = message.get('customer', {})
    email = customer.get('email')
    first_name = customer.get('firstName', 'Customer')
    tracking_number = message.get('trackingNumber', 'N/A')

    if not email:
        print(f"No email address for order {order_id}")
        return

    subject = f"Your Order Has Shipped - {order_id}"
    body = f"""
    Hi {first_name},

    Great news! Your order has shipped!

    Order ID: {order_id}
    Tracking Number: {tracking_number}

    Thanks for shopping with ShopFast!
    """

    print(f"Sending shipping notification to {email}")
    print(f"Subject: {subject}")
    print(f"Body: {body}")


def send_delivery_notification(message):
    """Send delivery notification email to customer."""
    order_id = message.get('orderId', 'Unknown')
    customer = message.get('customer', {})
    email = customer.get('email')
    first_name = customer.get('firstName', 'Customer')

    if not email:
        print(f"No email address for order {order_id}")
        return

    subject = f"Your Order Has Been Delivered - {order_id}"
    body = f"""
    Hi {first_name},

    Your order has been delivered!

    Order ID: {order_id}

    We hope you love your purchase. If you have any questions,
    please don't hesitate to contact us.

    Thanks for shopping with ShopFast!
    """

    print(f"Sending delivery notification to {email}")
    print(f"Subject: {subject}")
    print(f"Body: {body}")
