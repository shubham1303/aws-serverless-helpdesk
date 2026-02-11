// frontend/src/App.js
import React, { useState, useEffect } from 'react';
import { Amplify } from 'aws-amplify';
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import awsConfig from './aws-config';
import TicketList from './components/TicketList';
import CreateTicket from './components/CreateTicket';
import './App.css';

// Configure Amplify
Amplify.configure(awsConfig);

function App() {
  const [activeTab, setActiveTab] = useState('list');

  return (
    <Authenticator>
      {({ signOut, user }) => (
        <div className="app">
          <header className="app-header">
            <h1>🎫 Helpdesk Platform</h1>
            <div className="user-info">
              <span>Welcome, {user.signInDetails?.loginId || 'User'}</span>
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
              My Tickets
            </button>
            <button
              className={activeTab === 'create' ? 'tab active' : 'tab'}
              onClick={() => setActiveTab('create')}
            >
              Create Ticket
            </button>
          </nav>

          <main className="app-content">
            {activeTab === 'list' && <TicketList user={user} />}
            {activeTab === 'create' && <CreateTicket user={user} onSuccess={() => setActiveTab('list')} />}
          </main>

          <footer className="app-footer">
            <p>Built with AWS Serverless Architecture | React + Lambda + DynamoDB + Cognito</p>
          </footer>
        </div>
      )}
    </Authenticator>
  );
}

export default App;