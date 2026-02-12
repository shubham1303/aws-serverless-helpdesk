// frontend/src/components/TicketList.js
import React, { useState, useEffect } from 'react';
import { fetchAuthSession } from 'aws-amplify/auth';
import axios from 'axios';

function TicketList({ user, userRole }) {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchTickets();
  }, []);

  const fetchTickets = async () => {
    try {
      setLoading(true);
      setError(null);

      // Get auth token
      const session = await fetchAuthSession();
      const token = session.tokens?.idToken?.toString();

      if (!token) {
        throw new Error('No authentication token found');
      }

      // Call API
      const response = await axios.get(
        'https://4uw2quh8x5.execute-api.us-east-1.amazonaws.com/dev/tickets',
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      setTickets(response.data.tickets || []);
    } catch (err) {
      console.error('Error fetching tickets:', err);
      setError(err.response?.data?.error || err.message || 'Failed to load tickets');
    } finally {
      setLoading(false);
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority?.toLowerCase()) {
      case 'critical': return '#dc2626';
      case 'high': return '#ea580c';
      case 'medium': return '#ca8a04';
      case 'low': return '#16a34a';
      default: return '#6b7280';
    }
  };

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'open': return '#3b82f6';
      case 'in_progress': return '#f59e0b';
      case 'resolved': return '#10b981';
      case 'closed': return '#6b7280';
      default: return '#6b7280';
    }
  };

  if (loading) {
    return <div className="loading">Loading tickets...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <p className="error">⚠️ {error}</p>
        <button onClick={fetchTickets} className="btn-retry">
          Retry
        </button>
      </div>
    );
  }

  if (tickets.length === 0) {
    return (
      <div className="empty-state">
        <h3>No tickets yet</h3>
        <p>Create your first support ticket to get started!</p>
      </div>
    );
  }

  return (
    <div className="ticket-list">
      <div className="ticket-list-header">
        <h2>
          {userRole === 'customer' ? 'Your Tickets' : 'All Tickets'} ({tickets.length})
        </h2>
        <button onClick={fetchTickets} className="btn-refresh">
          🔄 Refresh
        </button>
      </div>

      <div className="tickets-grid">
        {tickets.map((ticket) => (
          <div key={ticket.ticket_id} className="ticket-card">
            <div className="ticket-header">
              <h3>{ticket.title}</h3>
              <span
                className="badge"
                style={{ backgroundColor: getPriorityColor(ticket.priority) }}
              >
                {ticket.priority}
              </span>
            </div>

            <p className="ticket-description">{ticket.description}</p>

            <div className="ticket-meta">
              <span
                className="status-badge"
                style={{ backgroundColor: getStatusColor(ticket.status) }}
              >
                {ticket.status}
              </span>
              <span className="ticket-id">{ticket.ticket_id}</span>
            </div>

            {/* Show assigned_to for agents/admins only */}
            {(userRole === 'agent' || userRole === 'admin') && (
              <div className="ticket-assigned">
                <small>Assigned to: {ticket.assigned_to || 'Unassigned'}</small>
              </div>
            )}

            {/* Show user_id for agents/admins only */}
            {(userRole === 'agent' || userRole === 'admin') && (
              <div className="ticket-user">
                <small>Customer: {ticket.user_id}</small>
              </div>
            )}

            <div className="ticket-footer">
              <small>Created: {new Date(ticket.created_at).toLocaleString()}</small>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default TicketList;