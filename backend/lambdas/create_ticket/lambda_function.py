import json
import boto3
import os
from datetime import datetime, timedelta
import uuid
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
tickets_table = dynamodb.Table(os.environ['TICKETS_TABLE'])
sla_table = dynamodb.Table(os.environ['SLA_TABLE'])

# SLA times in hours
SLA_TIMES = {
    'critical': 1,
    'high': 4,
    'medium': 24,
    'low': 72
}

# Helper class to convert Decimal to float/int for JSON serialization
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    """
    Create a new support ticket
    WITH RBAC: Always use authenticated user's email as user_id
    """
    try:
        # Extract user info from JWT (provided by API Gateway authorizer)
        user_email = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('email')
        
        if not user_email:
            return response(401, {'error': 'User email not found in token'})
        
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Validate required fields
        required_fields = ['title', 'description', 'priority']
        for field in required_fields:
            if field not in body:
                return response(400, {'error': f'Missing required field: {field}'})
        
        # Generate ticket ID
        ticket_id = f"TKT-{datetime.utcnow().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8]}"
        created_at = datetime.utcnow().isoformat()
        
        # Calculate SLA breach time
        priority = body.get('priority', 'medium')
        sla_hours = SLA_TIMES.get(priority, 24)
        breach_time = datetime.utcnow() + timedelta(hours=sla_hours)
        
        # Create ticket item
        # IMPORTANT: Use authenticated user's email as user_id (don't trust request body!)
        ticket_item = {
            'ticket_id': ticket_id,
            'created_at': created_at,
            'user_id': user_email,  # Always use JWT email!
            'title': body['title'],
            'description': body['description'],
            'status': 'open',
            'priority': priority,
            'category': body.get('category', 'general'),
            'assigned_to': body.get('assigned_to', 'unassigned'),
            'updated_at': created_at,
            'sla_breach_time': int(breach_time.timestamp())
        }
        
        # Save to DynamoDB
        tickets_table.put_item(Item=ticket_item)
        
        # Create SLA tracking entry
        sla_item = {
            'ticket_id': ticket_id,
            'priority': priority,
            'breach_time': int(breach_time.timestamp()),
            'created_at': created_at,
            'status': 'active'
        }
        sla_table.put_item(Item=sla_item)
        
        return response(201, {
            'message': 'Ticket created successfully',
            'ticket': ticket_item
        })
        
    except Exception as e:
        print(f"Error creating ticket: {str(e)}")
        return response(500, {'error': 'Internal server error'})

def response(status_code, body):
    """Helper function to format API Gateway response"""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
        },
        'body': json.dumps(body, cls=DecimalEncoder)
    }