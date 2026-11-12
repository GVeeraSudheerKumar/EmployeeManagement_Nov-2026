namespace ems.db;

using { ems.db.EmployeeMaster as employeeDb } from './schema';
using { ems.db.Departments as DepartmentDb } from './schema';

// View 1: Employee details with department information
entity EmployeeDetails as
    select from employeeDb.Employees as E
        left join DepartmentDb as D
            on E.Department.ID = D.ID
{
    key E.ID,
        E.EmployeeNo,
        E.FirstName,
        E.LastName,
        E.FullName,
        E.Email,
        E.Phone,
        E.JoiningDate,
        E.Salary,
        E.Status,

        E.Department,
        D.DepartmentID,
        D.DepartmentName,
        D.Location,
        D.ManagerName
};


// View 2: Leave requests with employee information
entity EmployeeLeaveDetails as
    select from employeeDb.LeaveRequests as L
        inner join employeeDb.Employees as E
            on L.Employee.ID = E.ID
{
    key L.ID,
        L.LeaveID,
        L.FromDate,
        L.ToDate,
        L.Reason,
        L.Status,

        E.ID as EmployeeID,
        E.EmployeeNo,
        E.FirstName,
        E.LastName,
        E.Email
};


// View 3: Department summary with employee count
entity DepartmentSummary as
    select from DepartmentDb as D
        left join employeeDb.Employees as E
            on E.Department.ID = D.ID
{
    key D.ID,
        D.DepartmentID,
        D.DepartmentName,
        D.Location,
        D.ManagerName,

        count(E.ID) as EmployeeCount : Integer//aggregation
}
group by
    D.ID,
    D.DepartmentID,
    D.DepartmentName,
    D.Location,
    D.ManagerName;
	
	
	




