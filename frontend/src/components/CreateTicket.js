// frontend/src/components/CreateTicket.js
import React, { useState } from 'react';
import { fetchAuthSession } from 'aws-amplify/auth';
import axios from 'axios';

function CreateTicket({ user, userRole, onSuccess }) {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    priority: 'medium',
    category: 'general',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    setError(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validation
    if (!formData.title.trim()) {
      setError('Title is required');
      return;
    }
    if (!formData.description.trim()) {
      setError('Description is required');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Get auth token
      const session = await fetchAuthSession();
      const token = session.tokens?.idToken?.toString();

      if (!token) {
        throw new Error('No authentication token found');
      }

      // Create ticket payload
      const payload = {
        title: formData.title.trim(),
        description: formData.description.trim(),
        priority: formData.priority,
        category: formData.category,
      };

      // Call API
      const response = await axios.post(
        'https://4uw2quh8x5.execute-api.us-east-1.amazonaws.com/dev/tickets',
        payload,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        }
      );

      console.log('Ticket created:', response.data);
      
      // Success!
      setSuccess(true);
      setFormData({
        title: '',
        description: '',
        priority: 'medium',
        category: 'general',
      });

      // Redirect after 2 seconds
      setTimeout(() => {
        setSuccess(false);
        onSuccess();
      }, 2000);

    } catch (err) {
      console.error('Error creating ticket:', err);
      setError(err.response?.data?.error || err.message || 'Failed to create ticket');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="success-message">
        <h2>✅ Ticket Created Successfully!</h2>
        <p>Redirecting to ticket list...</p>
      </div>
    );
  }

  return (
    <div className="create-ticket">
      <h2>Create New Support Ticket</h2>

      {error && <div className="error-banner">⚠️ {error}</div>}

      <form onSubmit={handleSubmit} className="ticket-form">
        <div className="form-group">
          <label htmlFor="title">Title *</label>
          <input
            type="text"
            id="title"
            name="title"
            value={formData.title}
            onChange={handleChange}
            placeholder="Brief description of the issue"
            maxLength="100"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="description">Description *</label>
          <textarea
            id="description"
            name="description"
            value={formData.description}
            onChange={handleChange}
            placeholder="Provide detailed information about your issue..."
            rows="6"
            required
          />
        </div>

        <div className="form-row">
          <div className="form-group">
            <label htmlFor="priority">Priority</label>
            <select
              id="priority"
              name="priority"
              value={formData.priority}
              onChange={handleChange}
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="category">Category</label>
            <select
              id="category"
              name="category"
              value={formData.category}
              onChange={handleChange}
            >
              <option value="general">General</option>
              <option value="technical">Technical</option>
              <option value="billing">Billing</option>
              <option value="feature_request">Feature Request</option>
            </select>
          </div>
        </div>

        <button
          type="submit"
          className="btn-submit"
          disabled={loading}
        >
          {loading ? 'Creating...' : 'Create Ticket'}
        </button>
      </form>
    </div>
  );
}

export default CreateTicket;