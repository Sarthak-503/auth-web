# Multi-Factor Authentication (MFA) Implementation

This guide outlines the tasks required to implement Multi-Factor Authentication (MFA) for a Single Sign-On (SSO) application using Google Authenticator and Microsoft Authenticator. The purpose of MFA is to enhance security by requiring users to verify their identity through a second authentication method. 

---

## Task List and Implementation

### Task 1: Check MFA Status from Application Configuration
- **Objective**: Retrieve and verify if MFA is enabled and mandatory from the application's configuration settings.
- **Implementation**: 
  - Access the configuration settings (environment variables or configuration service).
  - Retrieve and check values related to `MFA_ENABLED` and `MFA_MANDATORY`.
  - Expose these values as part of the authentication flow to determine if MFA should proceed.

---

### Task 2: Verify User Enrollment for MFA
- **Objective**: Confirm if the user has previously enrolled in MFA.
- **Implementation**: 
  - Query the user’s profile or account settings to check for MFA enrollment status.
  - Implement a service function to retrieve this data from the configuration.
  - Based on the user’s MFA status, route them to the next step in the authentication process.

---

### Task 3: Display MFA Page
- **Objective**: Show the MFA setup or verification page based on the user’s enrollment status.
- **Implementation**: 
  - Use React to render an MFA setup component if the user hasn’t enrolled, or a verification component if they are enrolled.
  - Handle state changes for the enrollment and verification status to render the correct content on the page.
  - Include logic to display Google Authenticator or Microsoft Authenticator as options for MFA.

---

### Task 4: Perform MFA Validation
- **Objective**: Validate the MFA token provided by the user.
- **Implementation**:
  - Use `otplib` to verify the MFA token input by the user.
  - For Google Authenticator, generate a secret, create an OTP URL, and validate tokens with `authenticator.verify()`.
  - For Microsoft Authenticator, generate a compatible secret and use the verification function.
  - Show success or error messages based on the validation result.

---


### Task 5: Implement Microsoft Authenticator Option using Azure
- **Objective**: Set up and verify Microsoft Authenticator for MFA through Azure Active Directory.
- **Implementation**:

  #### Step 1: Set Up an Application in Azure AD
  1. Go to the [Azure Active Directory](https://portal.azure.com/) portal.
  2. In the Azure AD blade, navigate to **App registrations** and select **New registration**.
  3. Enter a name for the application (e.g., `SSO-MFA-App`).
  4. Configure the **Redirect URI** to match the application’s URL where the authentication response will be sent.
  5. Click **Register** to create the application.

  #### Step 2: Configure the Microsoft Authenticator as an MFA Option
  1. In the **Azure Active Directory** portal, go to **Security** > **Authentication methods**.
  2. Under **Authentication methods**, select **Microsoft Authenticator** and ensure it’s enabled.
  3. Configure any additional settings as necessary, such as user groups or specific conditions for requiring Microsoft Authenticator.

  #### Step 3: Implement OAuth2/OIDC Flow for MFA Authentication
  - **Redirect to Microsoft’s Authorization Endpoint**:
    - Create a button that redirects users to Microsoft’s OAuth2 endpoint:
      ```
      https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize
      ```
    - Include the following parameters:
      - `client_id`: The client ID from your Azure AD app registration.
      - `response_type`: Set to `code`.
      - `redirect_uri`: The URI where Microsoft will send the authorization code.
      - `scope`: Set to `openid profile email offline_access`.
      - `state`: Optional parameter to maintain the request’s context.
  
  - **Exchange Authorization Code for Access Token**:
    - After the user completes the MFA via Microsoft Authenticator and is redirected back, use the authorization code to request an access token.
    - Make a `POST` request to:
      ```
      https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token
      ```
    - Include the following parameters:
      - `client_id`: The client ID from your Azure AD app registration.
      - `scope`: Set to the required scopes.
      - `code`: The authorization code from the previous step.
      - `redirect_uri`: The same redirect URI used previously (http://localhost:5173 for development).
      - `grant_type`: Set to `authorization_code`.
      - `client_secret`: (If applicable) Your Azure app’s client secret.

  - **Verify Token and Grant Access**:
    - Use the access token returned to verify the user’s MFA status.
    - If valid, grant access to the user by updating their session or issuing an application-specific token.

  #### Step 4: QR Code and OTP Verification
  - Generate a TOTP secret specifically for the user using `otplib`.
  - Use this secret to create a `otpauth` URL for the Microsoft Authenticator app:
    ```javascript
    const otpUrl = authenticator.keyuri(userId, 'YourAppName', secret);
    ```
  - Display this `otpUrl` as a QR code for the user to scan.

  #### Step 5: Validate Microsoft Authenticator OTP
  - Implement a verification step in the authentication flow:
    - Capture the OTP input from the user.
    - Use `authenticator.verify()` from `otplib` to validate the OTP against the stored TOTP secret.

---

## Additional Notes

- **Configuration and Environment Variables**: Ensure that sensitive data such as MFA keys and secrets are securely stored in environment variables or a secure configuration service.
- **Token Expiry and Error Handling**: Implement appropriate error messages for expired or invalid tokens, and consider adding retry limits or delays for security.
- **Libraries Used**:
  - `otplib` for generating and verifying MFA tokens.
  - `qrcode` for generating QR codes to be scanned by authenticator apps.
  
---


## Additional Notes

- **Configuration and Environment Variables**: Ensure that sensitive data such as MFA keys and secrets are securely stored in environment variables or a secure configuration service.
- **Token Expiry and Error Handling**: Implement appropriate error messages for expired or invalid tokens, and consider adding retry limits or delays for security.
- **Libraries Used**:
  - `otplib` for generating and verifying MFA tokens.
  - `qrcode` for generating QR codes to be scanned by authenticator apps.
  
---

