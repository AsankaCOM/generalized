## Google API configuration
​
### Generating API_KEY and ACCESS_TOKEN
​
#### Prerequisites
​
- You need a Google Account to access the Google API Console, request an API key, and register your application.
​
- Create a project in the [Google Developers Console](https://console.developers.google.com) and obtain [authorization credentials](https://console.developers.google.com/apis/credentials) so your application can submit API requests.
​
#### Obtain an API_KEY
For authentication and quota purposes, you will need to use the **Google Street View Publish API** with credentials generated from your Developers Console.
​

- Navigate to the [Credentials](https://console.developers.google.com/apis/credentials) page in your Developers Console.
​

- If you already have an API key, you can use the value from it. Otherwise, create a new one by selecting API key from the **New credentials** menu.
​
####  Obtain an ACCESS_TOKEN
In order to generate an access token, we need to crear a client ID and a client secret first.
​
- To obtain the client ID and client secret, go to the [Credentials](https://console.developers.google.com/apis/credentials) page in your Developers Console. If you do not have an existing OAuth 2.0 client, create a new OAuth 2.0 client ID by selecting OAuth client ID under the Create credentials menu and use the following configuration:
​
 - Application type:	Web application
 - Name:	(any value)
 - Authorized: JavaScript origins	(empty)
 - Authorized: redirect URIs	https://developers.google.com/oauthplayground
​
​
- Navigate to the [Google Developers OAuth 2.0 Playground](https://developers.google.com/oauthplayground/).
​
- Click the settings menu (gear icon on the top right), check **Use your own OAuth credentials** and input your Client ID and Client secret in the corresponding fields, and then click Close.
​
- Under **Step 1: Select & authorize APIs**, input the API scope `https://www.googleapis.com/auth/admin.directory.user` in the Input your own scopes field, then click Authorize APIs. A new page will open to confirm that you want to authorize the API. This scope is needed to allow the API to manage our google users.
​
- Click **Exchange authorization code for tokens**. This will populate the **Access token** field, which will contain your access token to be used in the next step. The access token expires in 60 minutes. You can select the option to auto-refresh the token before it expires, which will create a new token.
