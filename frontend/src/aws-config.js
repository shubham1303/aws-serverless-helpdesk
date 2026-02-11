// frontend/src/aws-config.js
// AWS Amplify configuration

const awsConfig = {
  Auth: {
    Cognito: {
      userPoolId: 'us-east-1_kVfHTlZsr',
      userPoolClientId: 'vouta33lt6cd129ddmt0s5att',
      loginWith: {
        email: true,
      },
      signUpVerificationMethod: 'code',
      userAttributes: {
        email: {
          required: true,
        },
        name: {
          required: true,
        },
      },
      allowGuestAccess: false,
      passwordFormat: {
        minLength: 8,
        requireLowercase: true,
        requireUppercase: true,
        requireNumbers: true,
        requireSpecialCharacters: false,
      },
    }
  },
  API: {
    REST: {
      helpdeskAPI: {
        endpoint: 'https://4uw2quh8x5.execute-api.us-east-1.amazonaws.com/dev',
        region: 'us-east-1'
      }
    }
  }
};

export default awsConfig;