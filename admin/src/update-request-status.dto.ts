import { IsEnum } from 'class-validator';
import { RequestStatus } from '../requests/assistance-request.entity';

export class UpdateRequestStatusDto {
  @IsEnum(RequestStatus)
  status!: RequestStatus;
}
