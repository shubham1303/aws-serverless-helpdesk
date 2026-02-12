// frontend/src/App.js
import React, { useState, useEffect } from 'react';
import { Amplify } from 'aws-amplify';
import { Authenticator } from '@aws-amplify/ui-react';
import { fetchAuthSession } from 'aws-amplify/auth';
import '@aws-amplify/ui-react/styles.css';
import awsConfig from './aws-config';
import TicketList from './components/TicketList';
import CreateTicket from './components/CreateTicket';
import './App.css';

// Configure Amplify
Amplify.configure(awsConfig);

function App() {
  const [activeTab, setActiveTab] = useState('list');
  const [userRole, setUserRole] = useState(null);
  const [currentUser, setCurrentUser] = useState(null);

  // Extract user role from Cognito groups
  const getUserRole = async () => {
    try {
      const session = await fetchAuthSession();
      const groups = session.tokens?.accessToken?.payload['cognito:groups'] || [];
      
      // Determine role based on group membership
      if (groups.includes('admins')) {
        setUserRole('admin');
      } else if (groups.includes('agents')) {
        setUserRole('agent');
      } else if (groups.includes('customers')) {
        setUserRole('customer');
      } else {
        setUserRole('customer'); // Default to customer
      }
    } catch (error) {
      console.error('Error getting user role:', error);
      setUserRole('customer'); // Default to customer on error
    }
  };

  // Get user role when user changes
  useEffect(() => {
    if (currentUser) {
      getUserRole();
    }
  }, [currentUser]);

  return (
    <Authenticator>
      {({ signOut, user }) => {
        // Update current user when it changes
        if (user && user !== currentUser) {
          setCurrentUser(user);
        }

        return (
          <div className="app">
            <header className="app-header">
              <h1>🎫 Helpdesk Platform</h1>
              <div className="user-info">
                <span>
                  {user.signInDetails?.loginId || 'User'}
                  {userRole && (
                    <span className="role-badge" style={{
                      marginLeft: '10px',
                      padding: '4px 8px',
                      borderRadius: '4px',
                      fontSize: '0.75rem',
                      fontWeight: 'bold',
                      backgroundColor: userRole === 'admin' ? '#ef4444' : 
                                      userRole === 'agent' ? '#3b82f6' : '#10b981',
                      color: 'white'
                    }}>
                      {userRole.toUpperCase()}
                    </span>
                  )}
                </span>
                <button onClick={signOut} className="btn-signout">
                  Sign Out
                </button>
              </div>
            </header>

            <nav className="tab-nav">
              <button
                className={activeTab === 'list' ? 'tab active' : 'tab'}
                onClick={() => setActiveTab('list')}
              >
                {userRole === 'customer' ? 'My Tickets' : 'All Tickets'}
              </button>
              <button
                className={activeTab === 'create' ? 'tab active' : 'tab'}
                onClick={() => setActiveTab('create')}
              >
                Create Ticket
              </button>
            </nav>

            <main className="app-content">
              {activeTab === 'list' && (
                <TicketList user={user} userRole={userRole} />
              )}
              {activeTab === 'create' && (
                <CreateTicket 
                  user={user} 
                  userRole={userRole}
                  onSuccess={() => setActiveTab('list')} 
                />
              )}
            </main>

            <footer className="app-footer">
              <p>Built with AWS Serverless Architecture | React + Lambda + DynamoDB + Cognito</p>
            </footer>
          </div>
        );
      }}
    </Authenticator>
  );
}

export default App;