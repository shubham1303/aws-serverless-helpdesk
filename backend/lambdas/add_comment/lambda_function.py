import json
import boto3
import os
from datetime import datetime
import uuid
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

dynamodb = boto3.resource('dynamodb')
comments_table = dynamodb.Table(os.environ['COMMENTS_TABLE'])

def lambda_handler(event, context):
    """
    Add a comment/reply to a ticket
    """
    try:
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Validate required fields
        required_fields = ['ticket_id', 'author_id', 'content']
        for field in required_fields:
            if field not in body:
                return response(400, {'error': f'Missing required field: {field}'})
        
        # Generate comment ID
        comment_id = f"CMT-{str(uuid.uuid4())[:8]}"
        created_at = datetime.utcnow().isoformat()
        
        # Create comment item
        comment_item = {
            'ticket_id': body['ticket_id'],
            'comment_id': comment_id,
            'created_at': created_at,
            'author_id': body['author_id'],
            'author_name': body.get('author_name', 'Unknown'),
            'content': body['content'],
            'is_internal': body.get('is_internal', False),
            'attachments': body.get('attachments', [])
        }
        
        # Save to DynamoDB
        comments_table.put_item(Item=comment_item)
        
        return response(201, {
            'message': 'Comment added successfully',
            'comment': comment_item
        })
        
    except Exception as e:
        print(f"Error adding comment: {str(e)}")
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