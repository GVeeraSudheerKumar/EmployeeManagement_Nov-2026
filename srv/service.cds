using {ems.db as db} from '../db/schema';
using {ems.db as empdb} from '../db/views';

//Defination
@requires: 'authenticated-user'
service EmployeeService @(path: 'EmployeeService') {

    //@Capabilties: { Insertable, Deletable: false }
    entity Departments @(restrict: [
        { grant: 'READ', to: ['User', 'Admin'] },
        { grant: 'WRITE', to: 'Admin' }
    ])  as projection on db.Departments;

    //@readonly
    
    @odata.draft.enabled
    entity Employees  @(restrict: [
        { grant: 'READ', to: ['User', 'Admin'] },
        { grant: 'WRITE', to: 'Admin' }
    ])   as projection on db.EmployeeMaster.Employees
        actions {
            action test();
        };


    entity LeaveRequests @(restrict: [
        { grant: 'READ', to: ['User', 'Admin'] },
        { grant: 'WRITE', to: 'Admin' }
    ]) as projection on db.EmployeeMaster.LeaveRequests
        actions {
            @requires: 'Admin'
            action ApproveLeave();
            @requires: 'Admin'
            action Reject(reason: String);
            @requires: 'Admin'
            action Cancel();

        }

    function getEmployeeCount() returns Integer;
};

// entity EmployeeDetails      as projection on empdb.EmployeeDetails;
// entity EmployeeLeaveDetails as projection on empdb.EmployeeLeaveDetails;
// entity DepartmentSummary    as projection on empdb.DepartmentSummary;


