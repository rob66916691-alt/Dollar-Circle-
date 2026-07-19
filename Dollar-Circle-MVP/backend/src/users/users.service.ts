import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
@Injectable()
export class UsersService {
 constructor(@InjectRepository(User) private repo:Repository<User>){}
 findByEmail(email:string){ return this.repo.findOne({where:{email:email.toLowerCase()}}); }
 async findById(id:string){ const u=await this.repo.findOne({where:{id}}); if(!u) throw new NotFoundException('User not found'); return u; }
 async create(data:Partial<User>){ if(!data.email) throw new ConflictException('Email required'); if(await this.findByEmail(data.email)) throw new ConflictException('Email already registered'); return this.repo.save(this.repo.create(data)); }
}
