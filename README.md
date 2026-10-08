# aws-serverless-helpdesk

A small ticketing app (think a stripped-down Zendesk) that I built to get hands-on
with Terraform and the AWS serverless stack. Customers sign up, open tickets and see
their own; agents and admins see everyone's.

Demo: https://d19zv988yhv8d8.cloudfront.net

## Stack

- **Frontend:** React, Amplify UI for the login screens, hosted on S3 behind CloudFront
- **Auth:** Cognito user pool with three groups (customers, agents, admins). A
  post-confirmation Lambda puts every new signup into `customers`.
- **API:** API Gateway REST API with a Cognito authorizer in front of Python 3.12 Lambdas
- **Data:** DynamoDB, mainly the `tickets` table with GSIs on user, status and assignee
- **Infra:** Terraform, split into modules (networking, dynamodb, lambda, cognito,
  api_gateway, s3_cloudfront), with remote state in S3 + a DynamoDB lock table
- **CI/CD:** GitHub Actions. A push to main builds the frontend, syncs it to S3,
  invalidates CloudFront and re-applies the Lambda module.

## What works

- sign up / sign in, role shown in the header
- creating a ticket (title, description, priority, category)
- each ticket gets an SLA deadline based on priority (critical 1h, high 4h, medium 24h, low 72h)
- ticket list: customers see their own, agents/admins see all and can filter by
  `status`, `user_id` or `assigned_to` through the API

## Not done yet / known issues

Being honest here since this is still a work in progress:

- `GET /tickets/{id}` and `PUT /tickets/{id}` don't work. The route param is `{id}`
  but the Lambdas read `ticket_id`. Easy fix, just haven't gotten to it.
- No UI yet for updating status, assigning tickets or comments. There's an
  `add_comment` Lambda but nothing reads comments back.
- CORS preflight is only set up on `/tickets`.
- I provisioned a VPC and a few extra tables (users, attachments, analytics) early on
  that nothing uses yet. The Lambdas don't run inside the VPC.

## Deploying it yourself

1. Create the state bucket and lock table:
   ```sh
   cd terraform/bootstrap
   terraform init && terraform apply
   ```
2. Change the backend bucket name in `terraform/environments/dev/main.tf` to yours, then:
   ```sh
   cd terraform/environments/dev
   terraform init && terraform apply
   ```
3. Put the Cognito pool/client IDs and the API URL from the Terraform outputs into
   `frontend/src/aws-config.js` and the two files in `frontend/src/components/` (they're
   hardcoded for now, moving them to env vars is on the list).
4. `cd frontend && npm install && npm run build`, then sync `build/` to the bucket.

For CI you'll need `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` repo secrets and
to update the bucket name and distribution ID at the top of
`.github/workflows/deploy.yml`.

Cost-wise it sits in the free tier for me. If you turn on the NAT gateway
(`enable_nat_gateway`), that alone is ~$30/month, so leave it off.

## Layout

```
backend/     lambda source
frontend/    react app
terraform/
  bootstrap/          state bucket + lock table
  environments/dev/   the actual stack
  modules/            one module per service
```
