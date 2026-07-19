import { Controller, Get, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from './user.entity';
@Controller('users')
export class UsersController { @UseGuards(JwtAuthGuard) @Get('me') me(@CurrentUser() user:User){ const {passwordHash,...safe}=user; return safe; } }
