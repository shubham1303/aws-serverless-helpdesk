# \# AWS Serverless Helpdesk Platform

# 

# A production-grade, cloud-native SaaS helpdesk and ticketing system built entirely on AWS using Infrastructure as Code (Terraform) and modern serverless architecture.

# 

# \## 🌐 Live Demo

# 

# \*\*Frontend:\*\* https://d19zv988yhv8d8.cloudfront.net

# 

# \*\*Test Credentials:\*\*

# \- Email: `test-customer@example.com`

# \- Password: `NewPass123!`

# 

# ---

# 

# \## 🏗️ Architecture

# 

# This project implements a complete serverless architecture using:

# 

# \- \*\*Frontend:\*\* React (hosted on S3 + CloudFront)

# \- \*\*API Layer:\*\* AWS API Gateway (REST API)

# \- \*\*Compute:\*\* AWS Lambda (Python 3.12)

# \- \*\*Database:\*\* DynamoDB (6 tables with GSIs)

# \- \*\*Authentication:\*\* AWS Cognito (User Pools + JWT)

# \- \*\*Networking:\*\* VPC with public/private subnets

# \- \*\*Infrastructure:\*\* 100% Terraform (IaC)

# 

# \### Architecture Diagram

# 

# ```

# ┌─────────────────────────────────────────────────────────┐

# │                     CloudFront CDN                      │

# │           (Global Edge Locations + HTTPS)               │

# └────────────────────┬────────────────────────────────────┘

# &nbsp;                    │

# &nbsp;                    ↓

# ┌────────────────────────────────────────────────────────┐

# │                    S3 Bucket                           │

# │              (React Static Files)                      │

# └────────────────────┬───────────────────────────────────┘

# &nbsp;                    │

# &nbsp;                    ↓ (API Calls)

# ┌────────────────────────────────────────────────────────┐

# │               AWS API Gateway                          │

# │          (REST Endpoints + CORS)                       │

# └────────────────────┬───────────────────────────────────┘

# &nbsp;                    │

# &nbsp;        ┌───────────┴───────────┐

# &nbsp;        ↓                       ↓

# ┌─────────────────┐    ┌──────────────────┐

# │  AWS Cognito    │    │  Lambda Functions│

# │  (Auth/JWT)     │    │  - create\_ticket │

# └─────────────────┘    │  - get\_tickets   │

# &nbsp;                      │  - update\_ticket │

# &nbsp;                      │  - add\_comment   │

# &nbsp;                      └────────┬─────────┘

# &nbsp;                               ↓

# &nbsp;                      ┌──────────────────┐

# &nbsp;                      │   DynamoDB       │

# &nbsp;                      │  - Tickets       │

# &nbsp;                      │  - Users         │

# &nbsp;                      │  - Comments      │

# &nbsp;                      │  - SLA Tracking  │

# &nbsp;                      └──────────────────┘

# ```

# 

# ---

# 

# \## ✨ Features

# 

# \### User Features

# \- 🔐 \*\*Secure Authentication\*\* - Email/password login with JWT tokens

# \- 🎫 \*\*Ticket Management\*\* - Create, view, and track support tickets

# \- 📊 \*\*Real-time Updates\*\* - Dynamic ticket list with status tracking

# \- 🎨 \*\*Modern UI\*\* - Responsive React interface with gradient design

# \- 📱 \*\*Mobile Responsive\*\* - Works on all device sizes

# 

# \### Technical Features

# \- ⚡ \*\*Serverless Architecture\*\* - Zero server management, auto-scaling

# \- 🔒 \*\*Security\*\* - API Gateway authorization, encrypted data, HTTPS

# \- 🌍 \*\*Global CDN\*\* - Fast load times worldwide via CloudFront

# \- 📈 \*\*Scalability\*\* - DynamoDB on-demand pricing, Lambda auto-scaling

# \- 🏗️ \*\*Infrastructure as Code\*\* - Complete Terraform automation

# \- 🔄 \*\*Multi-tenant Ready\*\* - User isolation and role-based access

# 

# ---

# 

# \## 🛠️ Tech Stack

# 

# \### Frontend

# \- React 18

# \- AWS Amplify (Auth)

# \- Axios (HTTP client)

# \- CSS3 (Custom styling with gradients)

# 

# \### Backend

# \- AWS Lambda (Python 3.12)

# \- API Gateway (REST)

# \- DynamoDB (NoSQL)

# \- Cognito (Authentication)

# 

# \### Infrastructure

# \- Terraform (IaC)

# \- AWS VPC (Networking)

# \- S3 (Storage)

# \- CloudFront (CDN)

# \- CloudWatch (Monitoring)

# 

# ---

# 

# \## 📁 Project Structure

# 

# ```

# helpdesk-platform/

# ├── terraform/

# │   ├── bootstrap/              # S3 backend for state

# │   ├── modules/

# │   │   ├── networking/         # VPC, subnets, security groups

# │   │   ├── dynamodb/           # Database tables

# │   │   ├── lambda/             # Function definitions

# │   │   ├── api\_gateway/        # REST API configuration

# │   │   ├── cognito/            # User authentication

# │   │   └── s3\_cloudfront/      # Frontend hosting

# │   └── environments/

# │       └── dev/                # Development environment

# ├── backend/

# │   └── lambdas/

# │       ├── create\_ticket/      # POST /tickets

# │       ├── get\_tickets/        # GET /tickets

# │       ├── update\_ticket/      # PUT /tickets/{id}

# │       └── add\_comment/        # POST /tickets/{id}/comments

# └── frontend/

# &nbsp;   └── src/

# &nbsp;       ├── components/         # React components

# &nbsp;       ├── aws-config.js       # AWS configuration

# &nbsp;       └── App.js              # Main application

# ```

# 

# ---

# 

# \## 🚀 Deployment

# 

# \### Prerequisites

# \- AWS Account

# \- Terraform >= 1.0

# \- AWS CLI configured

# \- Node.js >= 18

# \- Python >= 3.11

# 

# \### Deploy Infrastructure

# 

# ```bash

# \# 1. Bootstrap (one-time setup)

# cd terraform/bootstrap

# terraform init

# terraform apply

# 

# \# 2. Deploy all infrastructure

# cd ../environments/dev

# terraform init

# terraform apply

# ```

# 

# \### Deploy Frontend

# 

# ```bash

# \# 1. Build React app

# cd frontend

# npm install

# npm run build

# 

# \# 2. Upload to S3

# aws s3 sync build/ s3://YOUR-BUCKET-NAME/ --delete

# 

# \# 3. Invalidate CloudFront cache

# aws cloudfront create-invalidation \\

# &nbsp; --distribution-id YOUR-DIST-ID \\

# &nbsp; --paths "/\*"

# ```

# 

# ---

# 

# \## 💰 Cost Estimate

# 

# \### Development Environment

# \- \*\*Monthly Cost:\*\* ~$5-15

# &nbsp; - DynamoDB: ~$2 (on-demand)

# &nbsp; - Lambda: Free tier (1M requests)

# &nbsp; - S3: ~$0.50

# &nbsp; - CloudFront: ~$1

# &nbsp; - API Gateway: ~$3.50

# 

# \### Production (Moderate Traffic)

# \- \*\*Monthly Cost:\*\* ~$50-100

# &nbsp; - Based on 10,000 tickets/month

# &nbsp; - 100,000 API requests

# &nbsp; - 50GB storage

# 

# Most services have generous free tiers!

# 

# ---

# 

# \## 🔐 Security Features

# 

# \- ✅ JWT token-based authentication

# \- ✅ API Gateway request validation

# \- ✅ DynamoDB encryption at rest

# \- ✅ S3 bucket access via CloudFront OAI only

# \- ✅ VPC with public/private subnet isolation

# \- ✅ Security groups with least privilege

# \- ✅ HTTPS enforced via CloudFront

# \- ✅ Cognito password policies

# 

# ---

# 

# \## 📊 Database Schema

# 

# \### Tickets Table

# ```

# Primary Key: ticket\_id (HASH) + created\_at (RANGE)

# Attributes: title, description, status, priority, user\_id, assigned\_to

# GSI: UserIndex, StatusIndex, AssignedIndex

# ```

# 

# \### Users Table

# ```

# Primary Key: user\_id (HASH)

# Attributes: email, name, user\_type

# GSI: EmailIndex, UserTypeIndex

# ```

# 

# \### Comments Table

# ```

# Primary Key: ticket\_id (HASH) + comment\_id (RANGE)

# Attributes: author\_id, content, created\_at

# LSI: TimeIndex

# ```

# 

# ---

# 

# \## 🎯 API Endpoints

# 

# | Method | Endpoint | Description |

# |--------|----------|-------------|

# | POST | `/tickets` | Create new ticket |

# | GET | `/tickets` | List all tickets |

# | GET | `/tickets/{id}` | Get ticket details |

# | PUT | `/tickets/{id}` | Update ticket |

# | POST | `/tickets/{id}/comments` | Add comment |

# 

# All endpoints require JWT authentication via `Authorization: Bearer {token}` header.

# 

# ---

# 

# \## 🔄 Future Enhancements

# 

# \- \[ ] Role-based access control (Customer/Agent/Admin)

# \- \[ ] Email notifications (SES integration)

# \- \[ ] File attachments (S3 upload)

# \- \[ ] SLA monitoring with automated alerts

# \- \[ ] Admin dashboard with analytics

# \- \[ ] CI/CD pipeline (GitHub Actions)

# \- \[ ] Automated testing (Jest, Cypress)

# \- \[ ] Multi-language support

# 

# ---

# 

# \## 📝 Lessons Learned

# 

# \### Technical Decisions

# \- \*\*Serverless over EC2:\*\* Chose Lambda for zero server management and auto-scaling

# \- \*\*DynamoDB over RDS:\*\* NoSQL flexibility and serverless pricing model

# \- \*\*Terraform over CloudFormation:\*\* Better multi-cloud support and readability

# \- \*\*JWT over sessions:\*\* Stateless authentication for distributed systems

# 

# \### Challenges Overcome

# \- CloudFront deployment timing (10-15 min wait)

# \- Cognito schema requirements for user attributes

# \- API Gateway CORS configuration for React

# \- DynamoDB Decimal serialization in JSON responses

# 

# ---

# 

# \## 👤 Author

# 

# \*\*Shubham More\*\*

# 

# \- Portfolio: \[Your Portfolio URL]

# \- LinkedIn: \[Your LinkedIn]

# \- GitHub: \[@shubmore1303](https://github.com/shubmore1303)

# 

# ---

# 

# \## 📄 License

# 

# This project is open source and available under the \[MIT License](LICENSE).

# 

# ---

# 

# \## 🙏 Acknowledgments

# 

# Built as a portfolio project to demonstrate:

# \- AWS serverless architecture

# \- Infrastructure as Code (Terraform)

# \- Full-stack development (React + Python)

# \- DevOps practices

# \- Cloud-native design patterns

# 

# ---

# 

# \*\*⭐ If you found this project helpful, please consider giving it a star!\*\*

