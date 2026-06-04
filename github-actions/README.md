# CI/CD Pipeline — GitHub Actions

## What is a CI/CD pipeline?

A CI/CD pipeline automates the journey from code change to production deployment. Instead of manually SSHing into a server and running scripts, every change goes through a controlled, repeatable process automatically.

CI = Continuous Integration — code gets tested automatically on every push.
CD = Continuous Deployment — if tests pass, code deploys automatically to the right environment.

## Why do you need it?

Manual deployments are fragile. No test step means bugs reach production. No staging environment means production is your testing ground. No rollback plan means a bad deploy costs hours of manual recovery.

A pipeline solves all three. Code gets tested before it touches any environment. Staging gets the change first. Production only gets it after staging looks good. Rollback is one click.

## Three stages

**1. Test**
Runs automated checks on every code push. If anything fails, deployment stops immediately. Nothing broken ever reaches staging or production.

**2. Plan / Stage**
Terraform plans the infrastructure changes and deploys to the staging environment. Team verifies everything looks correct before touching production.

**3. Apply / Deploy**
If staging passes, the pipeline promotes the change to production automatically. No SSH. No manual scripts. No crossed fingers.

## When to use this

Every project that has more than one environment. If you're deploying straight to production without a test or staging step — you need this.

## File

`terraform-deploy.yml` — drop this into `.github/workflows/` in your project repo.
