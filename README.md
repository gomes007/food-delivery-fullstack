# 🍔 Food Delivery App - Full Stack Project

A comprehensive Food Delivery application built to simulate a real-world e-commerce scenario. This project demonstrates a complete software lifecycle, from the Backend API and Frontend Mobile-First design to automated Cloud Infrastructure deployment.

![Project Banner](https://via.placeholder.com/1000x300?text=Food+App+Banner)
## 🚀 Key Features

### 📱 Client Side (Mobile First)
- **Authentication:** Secure Login/Register with JWT.
- **Menu Navigation:** Browse categories (Burgers, Pizzas, Drinks) and products.
- **Cart System:** Add/remove items and calculate totals in real-time.
- **Checkout:** Integration with **Stripe** for credit card payments.
- **Order Tracking:** Real-time order status updates.

### 🛡️ Admin Dashboard
- **Order Management:** View incoming orders in real-time.
- **Status Updates:** Change order status (Pending -> Preparing -> Delivered).
- **Product Management:** Full CRUD for categories and products.

### ☁️ Infrastructure & DevOps
- **Infrastructure as Code (IaC):** AWS environment (EC2, Networks, Security Groups) provisioned via **Terraform**.
- **Containerization:** Application and Database fully containerized with **Docker**.
- **CI/CD Concepts:** Automated setup using User Data scripts on AWS.
- **Notifications:** Transactional emails sent via **MailerSend**.

---

## 🛠️ Tech Stack

### Backend
- **Language:** Java 21
- **Framework:** Spring Boot 3.5.6 (Web, Data JPA, Security)
- **Database:** MySQL
- **Security:** Spring Security + JWT (JSON Web Token)
- **Integration:** Stripe API (Payments), AWS S3 SDK (Storage)
- **Testing:** JUnit 5

### Frontend
- **Framework:** Next.js (React)
- **Styling:** Tailwind CSS
- **Components:** shadcn/ui
- **Http Client:** Axios

### DevOps & Cloud
- **Cloud Provider:** AWS (Amazon Web Services)
- **IaC:** Terraform
- **Container:** Docker & Docker Compose

---

## 🏗️ Architecture & Infrastructure

This project goes beyond localhost. The infrastructure was designed to be scalable and reproducible.

- **AWS EC2:** Hosts the application containers.
- **Docker Compose:** Orchestrates the Backend, Frontend, and MySQL containers.
- **Terraform:** Automatically provisions the VPC, Subnets, Internet Gateways, and EC2 instances.
- **Swap Memory:** Optimized configuration to run heavy Java workloads on AWS Free Tier (t2.micro).

---

## 🚦 Getting Started

### Prerequisites
- Docker & Docker Compose
- Java 21 (for local development)
- Node.js 18+ (for local development)

### 1. Clone the repository
```bash
git clone [https://github.com/SEU_USUARIO/food-delivery-fullstack.git](https://github.com/SEU_USUARIO/food-delivery-fullstack.git)
cd food-delivery-fullstack

2. Environment Variables
Create a .env file in the root directory and configure your keys (Stripe, Database, AWS):

Properties

# Database
DB_URL=jdbc:mysql://db:3306/foodapp
DB_USER=root
DB_PASSWORD=yourpassword

# JWT
JWT_SECRET=your_super_secret_key

# Stripe
STRIPE_API_KEY=sk_test_...

# MailerSend
MAIL_API_KEY=...
3. Run with Docker (Recommended)
You can spin up the entire stack (Front, Back, and DB) with a single command:

Bash

docker-compose up -d --build
Access the application:

Frontend: http://localhost:3000
Backend API: http://localhost:8080

📚 Acknowledgements & Certifications
This project was built consolidating knowledge from:
Udemy: "Build & Deploy a Full-Stack Food Delivery App" (Backend & Frontend development).
Data Science Academy: Infrastructure as Code (IaC) and Cloud Architecture.

Made with by Paulo Gomes
