import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
export enum UserRole { MEMBER='member', ADMIN='admin' }
@Entity({name:'users'})
export class User {
 @PrimaryGeneratedColumn('uuid') id!:string;
 @Column({unique:true}) email!:string;
 @Column({name:'password_hash'}) passwordHash!:string;
 @Column({name:'first_name',nullable:true}) firstName!:string|null;
 @Column({name:'last_name',nullable:true}) lastName!:string|null;
 @Column({type:'enum',enum:UserRole,default:UserRole.MEMBER}) role!:UserRole;
 @Column({default:true}) isActive!:boolean;
 @CreateDateColumn({name:'created_at'}) createdAt!:Date;
 @UpdateDateColumn({name:'updated_at'}) updatedAt!:Date;
}
