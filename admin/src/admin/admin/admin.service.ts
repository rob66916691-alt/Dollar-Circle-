
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { User } from '../users/user.entity';
import {
  AssistanceRequest,
  RequestStatus,
} from '../requests/assistance-request.entity';
import { Contribution } from '../contributions/contribution.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,

    @InjectRepository(AssistanceRequest)
    private readonly requestsRepository: Repository<AssistanceRequest>,

    @InjectRepository(Contribution)
    private readonly contributionsRepository: Repository<Contribution>,
  ) {}

  getRequests(status?: RequestStatus) {
    return this.requestsRepository.find({
      where: status ? { status } : {},
      order: { createdAt: 'DESC' },
    });
  }

  async updateRequestStatus(
    requestId: string,
    status: RequestStatus,
  ) {
    const request = await this.requestsRepository.findOne({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Assistance request not found');
    }

    request.status = status;

    return this.requestsRepository.save(request);
  }

  getUsers() {
    return this.usersRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async updateUserStatus(
    userId: string,
    isActive: boolean,
  ) {
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    user.isActive = isActive;

    return this.usersRepository.save(user);
  }

  getContributions() {
    return this.contributionsRepository.find({
      order: { createdAt: 'DESC' },
    });
  }
}
