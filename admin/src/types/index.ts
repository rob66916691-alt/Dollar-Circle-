export type RequestStatus = 'pending' | 'approved' | 'funded' | 'rejected';

export interface AssistanceRequest {
  id: string;
  userId: string;
  title: string;
  description: string;
  amountRequested: string | number;
  status: RequestStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface User {
  id: string;
  email: string;
  firstName?: string | null;
  lastName?: string | null;
  role: 'member' | 'admin';
  isActive: boolean;
  createdAt?: string;
}

export interface Contribution {
  id: string;
  contributorId: string;
  requestId: string;
  amount: string | number;
  status: 'pending' | 'paid' | 'failed';
  createdAt?: string;
}
