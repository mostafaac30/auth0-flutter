# Examples

- [Specifying an audience value](#specifying-an-audience-value)
- [Specifying scopes](#specifying-scopes)
- [Adding custom parameters to the login request](#adding-custom-parameters-to-the-login-request)
- [Logging out](#logging-out)
- [Custom schemes (Android only)](#custom-schemes-android-only)
- [Web Authentication](#web-authentication)
  - [Sign up](#sign-up)
  - [ID token validation](#id-token-validation)
    - [Custom domains](#custom-domains)
  - [Web Auth errors](#web-auth-errors)
- [Credentials Manager](#credentials-manager)
  - [Check for stored credentials](#check-for-stored-credentials)
  - [Retrieve stored credentials](#retrieve-stored-credentials)
  - [Custom implementations](#custom-implementations)
  - [Local authentication](#local-authentication)
  - [Credentials Manager errors](#credentials-manager-errors)
  - [Disable credentials storage](#disable-credentials-storage)
- [Authentication API](#authentication-api)
  - [Login with database connection](#login-with-database-connection)
  - [Sign up with database connection](#sign-up-with-database-connection)
  - [Retrieve user information](#retrieve-user-information)
  - [Renew credentials](#renew-credentials)
  - [API client errors](#api-client-errors)
- [Organizations](#organizations)
  - [Log in to an organization](#log-in-to-an-organization)
  - [Accept user invitations](#accept-user-invitations)
- [Bot Detection](#bot-detection)

## Specifying an audience value

Specify an [audience](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#control-access-token-audience) to obtain an access token that can be used to make authenticated requests to a backend. The audience value is the **API Identifier** of your [Auth0 API](https://auth0.com/docs/get-started/apis), for example `https://example.com/api`.

```dart
final credentials = await auth0
    .webAuthentication()
    .login(audience: 'YOUR_AUTH0_API_IDENTIFIER');
```

## Specifying scopes

Specify [scopes](https://auth0.com/docs/get-started/apis/scopes) to request permission to access protected resources, like the user profile. The default scope values are `openid`, `profile`, `email`, and `offline_access`. Regardless of the values specified, `openid` is always included.

```dart
final credentials = await auth0
    .webAuthentication()
    .login(scopes: {'profile', 'email', 'offline_access', 'read:todos'});
```

## Adding custom parameters to the login request

Specify additional parameters by passing a `parameters` map.

```dart
final credentials = await auth0
    .webAuthentication()
    .login(parameters: {'connection': 'github'});
```

## Logging out

Logging the user out involves clearing the Universal Login session cookie and then deleting the user's credentials from your app.

Call the `logout()` method in the `onPressed` callback of your **Logout** button. Once the session cookie has been cleared, `auth0_flutter` will automatically delete the user's credentials. If you're using your own credentials storage, make sure to delete the credentials afterward.

```dart
await auth0.webAuthentication().logout();
```

## Custom schemes (Android only)

On Android, `https` is used by default as the callback URL scheme. This works best for Android API 23+ if you're using [Android App Links](https://auth0.com/docs/get-started/applications/enable-android-app-links-support), but in previous Android versions, this may show the intent chooser dialog prompting the user to choose either your app or the browser. You can change this behavior by using a custom unique scheme so that Android opens the link directly with your app.

1. Update the `auth0Scheme` manifest placeholder on the `android/build.gradle` file.
2. Update the **Allowed Callback URLs** in the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/).
3. Pass the scheme value to the `webAuthentication()` method.

```dart
final webAuth = auth0.webAuthentication(scheme: 'YOUR_CUSTOM_SCHEME');

// Login
final credentials = await webAuth.login();

// Logout
await webAuth.logout();
```

> 💡 Note that custom schemes [can only have](https://developer.android.com/guide/topics/manifest/data-element) lowercase letters.

## Web Authentication

- [Web Auth signup](#web-auth-signup)
- [ID token validation](#id-token-validation)
- [Web Auth errors](#web-auth-errors)

### Sign up

You can make users land directly on the Signup page instead of the Login page by specifying the `'screen_hint': 'signup'` parameter. Note that this can be combined with `'prompt': 'login'`, which indicates whether you want to always show the authentication page or you want to skip if there's an existing session.

| Parameters                                   | No existing session   | Existing session              |
| :------------------------------------------- | :-------------------- | :---------------------------- |
| No extra parameters                          | Shows the login page  | Redirects to the callback URL |
| `'screen_hint': 'signup'`                    | Shows the signup page | Redirects to the callback URL |
| `'prompt': 'login'`                          | Shows the login page  | Shows the login page          |
| `'prompt': 'login', 'screen_hint': 'signup'` | Shows the signup page | Shows the signup page         |

```dart
final credentials = await auth0
    .webAuthentication()
    .login(parameters: {'screen_hint': 'signup'});
```

> ⚠️ The `screen_hint` parameter will work with the **New Universal Login Experience** without any further configuration. If you are using the **Classic Universal Login Experience**, you need to customize the [login template](https://manage.auth0.com/#/login_page) to look for this parameter and set the `initialScreen` [option](https://github.com/auth0/lock#database-options) of the `Auth0Lock` constructor.

### ID token validation

`auth0_flutter` automatically [validates](https://auth0.com/docs/secure/tokens/id-tokens/validate-id-tokens) the ID token obtained from Web Auth login, following the [OpenID Connect specification](https://openid.net/specs/openid-connect-core-1_0.html). This ensures the contents of the ID token have not been tampered with and can be safely used.

You can configure the ID token validation by passing an `IdTokenValidationConfig` instance. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/IdTokenValidationConfig-class.html) to learn more about the available configuration options.

```dart
const config = IdTokenValidationConfig(leeway: 10);
final credentials =
    await auth0.webAuthentication().login(idTokenValidationConfig: config);
```

#### Custom domains

Users of Auth0 Private Cloud with custom domains still on the [legacy behavior](https://auth0.com/docs/deploy/private-cloud/private-cloud-migrations/migrate-private-cloud-custom-domains) need to specify a custom issuer to match the Auth0 domain when performing Web Auth login. Otherwise, the ID token validation will fail.

```dart
const config =
    IdTokenValidationConfig(issuer: 'https://YOUR_AUTH0_DOMAIN/');
final credentials =
    await auth0.webAuthentication().login(idTokenValidationConfig: config);
```

### Web Auth errors

Web Auth will only throw `WebAuthenticationException` exceptions. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/WebAuthenticationException-class.html) to learn more about the available `WebAuthenticationException` properties.

```dart
try {
  final credentials = await auth0.webAuthentication().login();
  // ...
} on WebAuthenticationException catch (e) {
  print(e);
}
```

## Credentials Manager

- [Check for stored credentials](#check-for-stored-credentials)
- [Retrieve stored credentials](#retrieve-stored-credentials)
- [Custom implementations](#custom-implementations)
- [Local authentication](#local-authentication)
- [Credentials Manager errors](#credentials-manager-errors)
- [Disable credentials storage](#disable-credentials-storage)

The Credentials Manager utility allows you to securely store and retrieve the user's credentials. The credentials will be stored encrypted in Shared Preferences on Android, and in the Keychain on iOS.

> 💡 If you're using Web Auth, you do not need to manually store the credentials after login and delete them after logout; auth0_flutter does it automatically.

### Check for stored credentials

When the users open your app, check for valid credentials. If they exist, you can retrieve them and redirect the users to the app's main flow without any additional login steps.

```dart
final isLoggedIn = await auth0.credentialsManager.hasValidCredentials();

if (isLoggedIn) {
  // Retrieve the credentials and redirect to the main flow
} else {
  // No valid credentials exist, present the login page
}
```

### Retrieve stored credentials

The credentials will be automatically renewed (if expired) using the [refresh token](https://auth0.com/docs/secure/tokens/refresh-tokens). **This method is thread-safe.**

```dart
final credentials = await auth0.credentialsManager.credentials();
```

> 💡 You do not need to call `credentialsManager.storeCredentials()` afterward. The Credentials Manager automatically persists the renewed credentials.

### Custom implementations

flutter_auth0 exposes a built-in, default Credentials Manager implementation through the `credentialsManager` property. You can pass your own implementation to the `Auth0` constructor. If you're using Web Auth, this implementation will be used to store the user's credentials after login and delete them after logout.

```dart
final customCredentialsManager = CustomCredentialsManager();
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID',
    credentialsManager: customCredentialsManager);
// auth0.credentialsManager is now your CustomCredentialsManager instance
```

### Local authentication

You can enable an additional level of user authentication before retrieving credentials using the local authentication supported by the device, for example PIN or fingerprint on Android, and Face ID or Touch ID on iOS.

```dart
const localAuthentication =
    LocalAuthentication(title: 'Please authenticate to continue');
final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID',
    localAuthentication: localAuthentication);
final credentials = await auth0.credentialsManager.credentials();
```

Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/LocalAuthentication-class.html) to learn more about the available `LocalAuthentication` properties.

> ⚠️ Enabling local authentication will not work if you're using a custom Credentials Manager implementation. In that case, you will need to build support for local authentication into your custom implementation.

### Credentials Manager errors

The Credentials Manager will only throw `CredentialsManagerException` exceptions. You can find more information in the `details` property of the exception. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/CredentialsManagerException-class.html) to learn more about the available `CredentialsManagerException` properties.

```dart
try {
  final credentials = await auth0.credentialsManager.credentials();
  // ...
} on CredentialsManagerException catch (e) {
  print(e);
}
```

### Disable credentials storage

By default, `auth0_flutter` will automatically store the user's credentials after login and delete them after logout, using the built-in [Credentials Manager](#credentials-manager) instance. If you prefer to use your own credentials storage, you need to disable the built-in Credentials Manager.

```dart
final credentials =
    await auth0.webAuthentication(useCredentialsManager: false).login();
```

## Authentication API

- [Login with database connection](#login-with-database-connection)
- [Sign up with database connection](#sign-up-with-database-connection)
- [Retrieve user information](#retrieve-user-information)
- [Renew credentials](#renew-credentials)
- [API client errors](#api-client-errors)

The Authentication API exposes the AuthN/AuthZ functionality of Auth0, as well as the supported identity protocols like OpenID Connect, OAuth 2.0, and SAML.
We recommend using [Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login), but if you prefer to build your own UI you can use our API endpoints to do so. However, some Auth flows (grant types) are disabled by default so you must enable them on the settings page of your [Auth0 application](https://manage.auth0.com/#/applications/), as explained in [Update Grant Types](https://auth0.com/docs/get-started/applications/update-grant-types).

To log in or sign up with a username and password, the `Password` grant type needs to be enabled in your app. If you set the grants via the Management API you should activate both `http://auth0.com/oauth/grant-type/password-realm` and `Password`. Otherwise, the Auth0 Dashboard will take care of activating both when enabling `Password`.

> 💡 If your Auth0 account has the **Bot Detection** feature enabled, your requests might be flagged for verification. Check how to handle this scenario in the [Bot Detection](#bot-detection) section.

> ⚠️ The ID tokens obtained from Web Auth login are automatically validated by `auth0_flutter`, ensuring their contents have not been tampered with. **This is not the case for the ID tokens obtained from the Authentication API client.** You must [validate](https://auth0.com/docs/security/tokens/id-tokens/validate-id-tokens) any ID tokens received from the Authentication API client before using the information they contain.

### Login with database connection

```dart
final credentials = await auth0.api.login(
    usernameOrEmail: 'jane.smith@example.com',
    password: 'secret-password',
    connectionOrRealm: 'Username-Password-Authentication');

// Store the credentials afterward
final didStore =
    await auth0.credentialsManager.storeCredentials(credentials);
```

<details>
  <summary>Add an audience value</summary>

Specify an [audience](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#control-access-token-audience) to obtain an access token that can be used to make authenticated requests to a backend. The audience value is the **API Identifier** of your [Auth0 API](https://auth0.com/docs/get-started/apis), for example `https://example.com/api`.

```dart
final credentials = await auth0.api.login(
    usernameOrEmail: 'jane.smith@example.com',
    password: 'secret-password',
    connectionOrRealm: 'Username-Password-Authentication',
    audience: 'YOUR_AUTH0_API_IDENTIFIER');
```

</details>

<details>
  <summary>Add scope values</summary>

Specify [scopes](https://auth0.com/docs/get-started/apis/scopes) to request permission to access protected resources, like the user profile. The default scope values are `openid`, `profile`, `email`, and `offline_access`. Regardless of the values specified, `openid` is always included.

```dart
final credentials = await auth0.api.login(
    usernameOrEmail: 'jane.smith@example.com',
    password: 'secret-password',
    connectionOrRealm: 'Username-Password-Authentication',
    scopes: {'profile', 'email', 'offline_access', 'read:todos'});
```

</details>

### Sign up with database connection

```dart
final databaseUser = await auth0.api.signup(
    email: 'jane.smith@example.com',
    password: 'secret-password',
    connection: 'Username-Password-Authentication',
    userMetadata: {'first_name': 'Jane', 'last_name': 'Smith'});
```

> 💡 You might want to log the user in after signup. See [Login with database connection](#login-with-database-connection) above for an example.

### Retrieve user information

Fetch the latest user information from the `/userinfo` endpoint.

This method will yield a `UserProfile` instance. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/UserProfile-class.html) to learn more about its available properties.

```dart
final userProfile = await auth0.api.userInfo(accessToken: accessToken);
```

### Renew credentials

Use a [refresh token](https://auth0.com/docs/secure/tokens/refresh-tokens) to renew the user's credentials. It's recommended that you read and understand the refresh token process beforehand.

```dart
final newCredentials =
    await auth0.api.renewCredentials(refreshToken: refreshToken);

// Store the credentials afterward
final didStore =
    await auth0.credentialsManager.storeCredentials(newCredentials);
```

> 💡 To obtain a refresh token, make sure your Auth0 application has the **refresh token** [grant enabled](https://auth0.com/docs/get-started/applications/update-grant-types). If you are also specifying an audience value, make sure that the corresponding Auth0 API has the **Allow Offline Access** [setting enabled](https://auth0.com/docs/get-started/apis/api-settings#access-settings).

### API client errors

The Authentication API client will only throw `ApiException` exceptions. You can find more information in the `details` property of the exception. Check the [API documentation](https://pub.dev/documentation/auth0_flutter_platform_interface/latest/auth0_flutter_platform_interface/ApiException-class.html) to learn more about the available `ApiException` properties.

```dart
try {
  final credentials = await auth0.api.login(
      usernameOrEmail: email,
      password: password,
      connectionOrRealm: connection);
  // ...
} on ApiException catch (e) {
  print(e);
}
```

## Organizations

[Organizations](https://auth0.com/docs/manage-users/organizations) is a set of features that provide better support for developers who build and maintain SaaS and Business-to-Business (B2B) applications.

> 💡 Organizations is currently only available to customers on our Enterprise and Startup subscription plans.

### Log in to an organization

```dart
final credentials = await auth0
    .webAuthentication()
    .login(organizationId: 'YOUR_AUTH0_ORGANIZATION_ID');
```

### Accept user invitations

To accept organization invitations your app needs to support [deep linking](https://docs.flutter.dev/development/ui/navigation/deep-linking), as invitation links are HTTPS-only. Tapping on the invitation link should open your app.

When your app gets opened by an invitation link, grab the invitation URL and pass it to the `login()` method.

```dart
final credentials =
    await auth0.webAuthentication().login(invitationUrl: url);
```

## Bot Detection

If you are performing database login/signup via the Authentication API and would like to use the [Bot Detection](https://auth0.com/docs/secure/attack-protection/bot-detection) feature, you need to handle the `isVerificationRequired` error. It indicates that the request was flagged as suspicious and an additional verification step is necessary to log the user in. That verification step is web-based, so you need to use Web Auth to complete it.

```dart
try {
  final credentials = await auth0.api.login(
      usernameOrEmail: email,
      password: password,
      connectionOrRealm: connection,
      scopes: scopes);
  // ...
} on ApiException catch (e) {
  if (e.isVerificationRequired) {
    final credentials = await auth0.webAuthentication().login(
        scopes: scopes,
        useEphemeralSession: true, // Otherwise a session cookie will remain (iOS-only)
        parameters: {
          'connection': connection,
          'login_hint': email // So the user doesn't have to type it again
        });
    // ...
  }
}
```
