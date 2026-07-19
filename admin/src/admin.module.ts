import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

import { User } from '../users/user.entity';
import { AssistanceRequest } from '../requests/assistance-request.entity';
import { Contribution } from '../contributions/contribution.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      AssistanceRequest,
      Contribution,
    ]),
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
