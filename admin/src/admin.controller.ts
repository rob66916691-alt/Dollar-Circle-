import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AdminService } from './admin.service';
import { AdminGuard } from './admin.guard';
import { UpdateRequestStatusDto } from './update-request-status.dto';
import { UpdateUserStatusDto } from './update-user-status.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RequestStatus } from '../requests/assistance-request.entity';

@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('requests')
  getRequests(@Query('status') status?: RequestStatus) {
    return this.adminService.getRequests(status);
  }

  @Patch('requests/:id/status')
  updateRequestStatus(
    @Param('id') id: string,
    @Body() body: UpdateRequestStatusDto,
  ) {
    return this.adminService.updateRequestStatus(id, body.status);
  }

  @Get('users')
  getUsers() {
    return this.adminService.getUsers();
  }

  @Patch('users/:id/status')
  updateUserStatus(
    @Param('id') id: string,
    @Body() body: UpdateUserStatusDto,
  ) {
    return this.adminService.updateUserStatus(id, body.isActive);
  }

  @Get('contributions')
  getContributions() {
    return this.adminService.getContributions();
  }
}
