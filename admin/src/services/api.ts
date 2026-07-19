import axios from 'axios';
import type { AssistanceRequest, Contribution, User } from '../types';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export async function adminLogin(email: string, password: string): Promise<void> {
  const response = await api.post('/auth/login', { email, password });
  const token = response.data?.accessToken;
  if (!token) throw new Error('No access token returned');
  localStorage.setItem('admin_access_token', token);
}

export function adminLogout(): void {
  localStorage.removeItem('admin_access_token');
}

export function hasAdminToken(): boolean {
  return Boolean(localStorage.getItem('admin_access_token'));
}

export async function getCurrentUser(): Promise<User> {
  const response = await api.get('/users/me');
  return response.data;
}

export async function getPendingRequests(): Promise<AssistanceRequest[]> {
  const response = await api.get('/admin/requests?status=pending');
  return response.data;
}

export async function getAllRequests(): Promise<AssistanceRequest[]> {
  const response = await api.get('/admin/requests');
  return response.data;
}

export async function updateRequestStatus(
  requestId: string,
  status: AssistanceRequest['status'],
): Promise<AssistanceRequest> {
  const response = await api.patch(`/admin/requests/${requestId}/status`, { status });
  return response.data;
}

export async function getUsers(): Promise<User[]> {
  const response = await api.get('/admin/users');
  return response.data;
}

export async function setUserActive(userId: string, isActive: boolean): Promise<User> {
  const response = await api.patch(`/admin/users/${userId}/status`, { isActive });
  return response.data;
}

export async function getContributions(): Promise<Contribution[]> {
  const response = await api.get('/admin/contributions');
  return response.data;
}
