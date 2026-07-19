import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { RequestsModule } from './requests/requests.module';
import { ContributionsModule } from './contributions/contributions.module';
@Module({ imports: [
  ConfigModule.forRoot({ isGlobal: true }),
  TypeOrmModule.forRootAsync({ inject:[ConfigService], useFactory:(c:ConfigService)=>({
    type:'postgres', host:c.getOrThrow('DATABASE_HOST'), port:Number(c.get('DATABASE_PORT') ?? 5432),
    username:c.getOrThrow('DATABASE_USER'), password:c.getOrThrow('DATABASE_PASSWORD'), database:c.getOrThrow('DATABASE_NAME'),
    autoLoadEntities:true, synchronize:false
  })}),
  AuthModule, UsersModule, RequestsModule, ContributionsModule
]})
export class AppModule {}
