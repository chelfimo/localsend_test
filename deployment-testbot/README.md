# Flagsmith - TestBot Deployment

TestBot-compatible deployment scripts for Flagsmith feature flag management platform.

## Files

- **setup.sh** - Starts Flagsmith, creates admin, org, project, and feature flags
- **get-token.sh** - Outputs API authentication token
- **docker-compose.yml** - Service configuration (includes PostgreSQL)

## TestBot Configuration

```yaml
- uses: skyramp/testbot@v1
  with:
    skyramp_license_file: ${{ secrets.SKYRAMP_LICENSE }}
    cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
    target_setup_command: './deployment-testbot/flagsmith/setup.sh'
    target_ready_check_command: 'curl -f http://localhost:8080/health'
    auth_token_command: './deployment-testbot/flagsmith/get-token.sh'
    target_teardown_command: 'docker-compose -f deployment-testbot/flagsmith/docker-compose.yml down'
```

## Application Details

- **Port:** 8080
- **API Base:** http://localhost:8080/api/v1
- **Web UI:** http://localhost:8080
- **Health Endpoint:** /health
- **Auth Type:** Token (Django REST Framework)
- **Credentials:** admin@test.com / TestPass123!

## API Endpoints

- `GET /api/v1/organisations/` - List organizations
- `POST /api/v1/organisations/` - Create organization
- `GET /api/v1/projects/` - List projects
- `POST /api/v1/projects/` - Create project
- `GET /api/v1/environments/` - List environments
- `GET /api/v1/projects/{id}/features/` - List features
- `POST /api/v1/projects/{id}/features/` - Create feature
- `GET /api/v1/flags/` - Get flags (SDK endpoint)

## Manual Testing

```bash
# Start services
./setup.sh

# Get token
TOKEN=$(./get-token.sh)

# Test API
curl http://localhost:8080/api/v1/organisations/ \
  -H "Authorization: Token $TOKEN"

# Stop services
docker-compose down
```

## Test Data

Setup script creates:
- **Admin user:** admin@test.com
- **Organization:** TestBot Org
- **Project:** TestBot Project
- **Feature flags:** new_dashboard, beta_features
- **Environments:** Development, Production (auto-created)
