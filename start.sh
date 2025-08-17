#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE} Starting DBT + Airflow Docker Environment${NC}"
echo "**********************************************************"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED} Docker is not running. Please start Docker Desktop first.${NC}"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED} docker-compose is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${YELLOW} Building and starting services...${NC}"

# Build and start services
docker-compose up -d --build

# Wait for services to be ready
echo -e "${YELLOW} Waiting for services to be ready...${NC}"
sleep 30

# Check service status
echo -e "${BLUE} Service Status:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN} Environment is ready!${NC}"
echo ""
echo -e "${BLUE} Access your services:${NC}"
echo -e "   • Airflow Web UI: ${GREEN}http://localhost:8080${NC} (admin/admin)"
echo -e "   • Airflow Flower: ${GREEN}http://localhost:5555${NC}"
echo -e "   • PostgreSQL: ${GREEN}localhost:5432${NC} (airflow/airflow)"
echo ""
echo -e "${BLUE} Useful commands:${NC}"
echo -e "   • View logs: ${YELLOW}docker-compose logs -f${NC}"
echo -e "   • Stop services: ${YELLOW}docker-compose down${NC}"
echo -e "   • Restart services: ${YELLOW}docker-compose restart${NC}"
echo -e "   • Access DBT container: ${YELLOW}docker-compose exec dbt bash${NC}"
echo ""
echo -e "${BLUE} Next steps:${NC}"
echo -e "   1. Open Airflow UI and create your first DAG"
echo -e "   2. Run DBT commands: ${YELLOW}docker-compose exec dbt dbt debug${NC}"
echo -e "   3. Check the README-Docker.md for detailed instructions"