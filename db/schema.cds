namespace ems.db; //package declaration

using {cuid, managed} from '@sap/cds/common';//import statement for standard ascepts

using {ems.db as commons} from './commons'; //import statement

context EmployeeMaster { //Employee master data


        entity Employees : cuid, managed, commons.address {

                EmployeeNo                      : commons.Guid;//String(20)

                FirstName                       : String(30);

                LastName                        : String(30);

                FullName                        : String(50);

                Email                           : String(100);

                Phone                           : String(20);

                JoiningDate                     : Date;

                Salary                          : Decimal(15, 2);

                Status                          : String(20);                

                // Many employees can belong to one department(many to one relation)
                Department                      : Association to Departments;

                //Many LeaveRequest can belong to one Employee (one to many relation)
                LeaveRequests                   : Composition of many LeaveRequests
                                                          on LeaveRequests.Employee = $self;

                virtual StatusCriticality       : Integer @Core.Computed;

                // virtual SalaryFieldControl      : Integer @Core.Computed  @odata.Type: 'Edm.Byte';

                // virtual JoiningDateFieldControl : Integer @Core.Computed  @odata.Type: 'Edm.Byte';

                virtual SalaryFieldControl      : UInt8   @Core.Computed;
                virtual JoiningDateFieldControl : UInt8   @Core.Computed;
        }

        entity LeaveRequests : cuid, managed {

                LeaveID                   : commons.Guid;

                FromDate                  : Date;

                ToDate                    : Date;

                Reason                    : String(300);

                Status                    : String(20);

                //one LeaveRequest has associated with employee(many to one relation)
                Employee                  : Association to Employees; //foregin key

                virtual StatusCriticality : Integer @Core.Computed;

                virtual CanApprove        : Boolean @Core.Computed;

        }

}

entity Departments : cuid, managed {

        DepartmentID   : commons.Guid;

        DepartmentName : String(30);

        Location       : String(30);

        ManagerName    : String(50);

        //one Department has many Employees (one to many relation)
        Employees      : Association to many EmployeeMaster.Employees
                                 on Employees.Department = $self;

}
