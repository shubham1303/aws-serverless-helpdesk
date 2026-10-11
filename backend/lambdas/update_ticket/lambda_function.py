import json
import boto3
import os
from datetime import datetime
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
    Update a ticket's status, priority, category, or other fields
    WITH RBAC: Customers can only update their own tickets
    """
    try:
        # Extract user info from JWT
        user_email = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('email')
        user_groups = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('cognito:groups', '')
        
        # Determine user role
        is_customer = 'customers' in user_groups
        
        # Get ticket ID from path (the API route is /tickets/{id})
        path_params = event.get('pathParameters', {}) or {}
        ticket_id = path_params.get('id') or path_params.get('ticket_id')
        if not ticket_id:
            return response(400, {'error': 'ticket_id is required'})

        # Parse update data (API Gateway sends body=None when there isn't one)
        body = json.loads(event.get('body') or '{}')
        
        # Get existing ticket
        result = tickets_table.query(
            KeyConditionExpression=Key('ticket_id').eq(ticket_id),
            Limit=1
        )
        
        if not result['Items']:
            return response(404, {'error': 'Ticket not found'})
        
        existing_ticket = result['Items'][0]
        
        # RBAC: Customers can only update their own tickets
        if is_customer and existing_ticket.get('user_id') != user_email:
            return response(403, {'error': 'Access denied: You can only update your own tickets'})
        
        # RBAC: Customers cannot change certain fields
        if is_customer:
            # Customers can only update: description (add info)
            # They CANNOT change: status, priority, assigned_to
            restricted_fields = ['status', 'priority', 'assigned_to', 'category']
            for field in restricted_fields:
                if field in body:
                    return response(403, {'error': f'Access denied: Customers cannot modify {field}'})
        
        # Build update expression
        update_expr = "SET updated_at = :updated_at"
        expr_values = {':updated_at': datetime.utcnow().isoformat()}
        expr_names = {}
        
        # Allowed fields to update (for agents/admins)
        allowed_fields = ['status', 'priority', 'category', 'assigned_to', 'title', 'description']
        
        for field in allowed_fields:
            if field in body:
                # use a name placeholder for every field, a few of these are
                # DynamoDB reserved words (status, description...)
                update_expr += f", #{field} = :{field}"
                expr_names[f'#{field}'] = field
                expr_values[f':{field}'] = body[field]

        # Update the ticket. boto3 rejects ExpressionAttributeNames=None, so only
        # pass it when there's something in it
        update_args = {
            'Key': {
                'ticket_id': ticket_id,
                'created_at': existing_ticket['created_at']
            },
            'UpdateExpression': update_expr,
            'ExpressionAttributeValues': expr_values,
            'ReturnValues': 'ALL_NEW'
        }
        if expr_names:
            update_args['ExpressionAttributeNames'] = expr_names
        response_data = tickets_table.update_item(**update_args)
        
        return response(200, {
            'message': 'Ticket updated successfully',
            'ticket': response_data['Attributes']
        })
        
    except Exception as e:
        print(f"Error updating ticket: {str(e)}")
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