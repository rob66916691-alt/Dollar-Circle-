import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config'; import { JwtService } from '@nestjs/jwt'; import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service'; import { RegisterDto } from './dto/register.dto'; import { LoginDto } from './dto/login.dto';
@Injectable() export class AuthService {
 constructor(private users:UsersService,private jwt:JwtService,private config:ConfigService){}
 async register(d:RegisterDto){ const u=await this.users.create({email:d.email.toLowerCase(),passwordHash:await bcrypt.hash(d.password,12),firstName:d.firstName??null,lastName:d.lastName??null}); return this.token(u.id,u.email,u.role); }
 async login(d:LoginDto){ const u=await this.users.findByEmail(d.email); if(!u||!(await bcrypt.compare(d.password,u.passwordHash))) throw new UnauthorizedException('Invalid email or password'); return this.token(u.id,u.email,u.role); }
 private async token(sub:string,email:string,role:string){ return {accessToken:await this.jwt.signAsync({sub,email,role},{secret:this.config.getOrThrow('JWT_SECRET'),expiresIn:this.config.get('JWT_EXPIRES_IN')??'7d'})}; }
}
