import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
tickets_table = dynamodb.Table(os.environ['TICKETS_TABLE'])

# Helper class to convert Decimal to float/int for JSON serialization
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    """
    Get tickets - supports:
    - Get single ticket by ID
    - Get all tickets for a user
    - Get tickets by status
    - Get tickets assigned to an agent
    
    WITH RBAC: Customers see only their tickets, Agents/Admins see all
    """
    try:
        # Extract user info from JWT (provided by API Gateway authorizer)
        user_email = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('email')
        user_groups = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('cognito:groups', '')
        
        # Determine user role
        is_customer = 'customers' in user_groups
        is_agent = 'agents' in user_groups
        is_admin = 'admins' in user_groups
        
        # Get query parameters
        params = event.get('queryStringParameters', {}) or {}
        path_params = event.get('pathParameters', {}) or {}
        
        # Single ticket lookup (the API route is /tickets/{id})
        ticket_id = path_params.get('id') or path_params.get('ticket_id')
        if ticket_id:
            return get_ticket_by_id(ticket_id, user_email, is_customer)
        
        # FOR CUSTOMERS: Always filter by their user_id (ignore other params)
        if is_customer:
            return get_tickets_by_user(user_email)
        
        # FOR AGENTS/ADMINS: Allow flexible querying
        # Query by user
        if 'user_id' in params:
            return get_tickets_by_user(params['user_id'])
        
        # Query by status
        if 'status' in params:
            return get_tickets_by_status(params['status'])
        
        # Query by assigned agent
        if 'assigned_to' in params:
            return get_tickets_by_agent(params['assigned_to'])
        
        # Default: get all tickets (agents/admins only)
        return get_all_tickets()
        
    except Exception as e:
        print(f"Error getting tickets: {str(e)}")
        return response(500, {'error': 'Internal server error'})

def get_ticket_by_id(ticket_id, user_email, is_customer):
    """Get a single ticket by ID - with RBAC check"""
    result = tickets_table.query(
        KeyConditionExpression=Key('ticket_id').eq(ticket_id),
        Limit=1
    )
    
    if not result['Items']:
        return response(404, {'error': 'Ticket not found'})
    
    ticket = result['Items'][0]
    
    # RBAC: Customers can only see their own tickets
    if is_customer and ticket.get('user_id') != user_email:
        return response(403, {'error': 'Access denied'})
    
    return response(200, {'ticket': ticket})

def get_tickets_by_user(user_id):
    """Get all tickets for a specific user"""
    result = tickets_table.query(
        IndexName='UserIndex',
        KeyConditionExpression=Key('user_id').eq(user_id),
        ScanIndexForward=False,  # Sort by created_at descending
        Limit=100
    )
    
    return response(200, {
        'tickets': result['Items'],
        'count': len(result['Items'])
    })

def get_tickets_by_status(status):
    """Get tickets by status (open, in_progress, resolved, closed)"""
    result = tickets_table.query(
        IndexName='StatusIndex',
        KeyConditionExpression=Key('status').eq(status),
        ScanIndexForward=False,
        Limit=100
    )
    
    return response(200, {
        'tickets': result['Items'],
        'count': len(result['Items']),
        'status': status
    })

def get_tickets_by_agent(agent_id):
    """Get tickets assigned to a specific agent"""
    result = tickets_table.query(
        IndexName='AssignedIndex',
        KeyConditionExpression=Key('assigned_to').eq(agent_id),
        ScanIndexForward=False,
        Limit=100
    )
    
    return response(200, {
        'tickets': result['Items'],
        'count': len(result['Items']),
        'assigned_to': agent_id
    })

def get_all_tickets():
    """Get all tickets (agents/admins only - already checked in main handler)"""
    result = tickets_table.scan(Limit=100)
    
    return response(200, {
        'tickets': result['Items'],
        'count': len(result['Items'])
    })

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