# Cognito — User Authentication

## What it is

Cognito is AWS's managed authentication service. It handles user sign up, sign in, password resets, and token issuance so you don't have to build any of that yourself.

## Why you need it

Every application that has users needs to answer two questions — who are you, and are you allowed in? Cognito answers the first question. It verifies a user's identity and issues a JWT token that proves they are who they say they are. Your API Gateway or ALB then checks that token on every request.

## How it fits into a real architecture

User hits your login page → credentials go to Cognito → Cognito verifies and issues a JWT → user sends JWT with every API request → API Gateway validates the JWT → request reaches Lambda or your app layer

Without Cognito you would need to build your own user database, password hashing, session management, and token logic. Cognito handles all of that as a managed service.

## Key concepts

**User Pool** — the directory of your users. Stores usernames, emails, passwords, and profile attributes. Handles sign up flows, email verification, MFA, and password policies.

**App Client** — the entry point your application uses to talk to the User Pool. Every app that authenticates against your User Pool needs its own App Client. Think of it as the key your frontend uses to unlock the door.

**JWT tokens** — Cognito issues three tokens on successful login: ID token (who the user is), Access token (what they can do), Refresh token (used to get new tokens without logging in again). API Gateway validates the Access token on every request.

## Tips and gotchas

- App Client should have `prevent_user_existence_errors` enabled — stops attackers from probing whether an email exists in your pool
- Password policy is set on the User Pool, not the App Client
- For API Gateway JWT authorizer, point to the Access token, not the ID token
- User Pools are regional — if you go multi-region you need a User Pool in each region
- You cannot change the username attribute after a User Pool is created — decide upfront whether users log in with email or username
