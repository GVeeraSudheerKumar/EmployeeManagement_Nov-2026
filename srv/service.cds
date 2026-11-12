using {ems.db as db} from '../db/schema';
using {ems.db as empdb} from '../db/views';

//Defination
service EmployeeService @(path: 'EmployeeService') {

    //@Capabilties: { Insertable, Deletable: false }
    entity Departments   as projection on db.Departments;

    //@readonly
    @odata.draft.enabled
    entity Employees     as projection on db.EmployeeMaster.Employees
        actions {
            action test();
        };


    entity LeaveRequests as projection on db.EmployeeMaster.LeaveRequests
        actions {
            action ApproveLeave();

            action Reject(reason: String);

            action Cancel();

        }

    function getEmployeeCount() returns Integer;
};

// entity EmployeeDetails      as projection on empdb.EmployeeDetails;
// entity EmployeeLeaveDetails as projection on empdb.EmployeeLeaveDetails;
// entity DepartmentSummary    as projection on empdb.DepartmentSummary;


