import { createParamDecorator,ExecutionContext } from '@nestjs/common'; export const CurrentUser=createParamDecorator((_d:unknown,c:ExecutionContext)=>c.switchToHttp().getRequest().user);
