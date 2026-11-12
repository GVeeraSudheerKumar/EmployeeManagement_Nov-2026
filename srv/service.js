const cds = require('@sap/cds');//import statement
const { data } = require('@sap/cds/lib/dbs/cds-deploy');
const { INSERT } = require('@sap/cds/lib/ql/cds-ql');
const { SELECT, UPDATE } = cds.ql;


module.exports = cds.service.impl(async function () {//main function 

    const { Employees, Departments, LeaveRequests } = this.entities;//declaring the entities
    //const { Employees } = this.entities;
    //Standard Approach of defining the event handlers 
    this.before("CREATE", Employees, async (req) => {
        await validateEmployee(req, Employees);
    });
    this.before("UPDATE", Employees, async (req) => {
        await validateEmployee(req, Employees);
    });
    this.before("CREATE", LeaveRequests, async (req) => {
        await validateLeaveRequest(req, Employees, LeaveRequests);
    });

    this.on('test', (req, res) => {
        console.log("I am a test action");
    });

    this.on('ApproveLeave', LeaveRequests, async (req) => {
        await approveLeave(req, LeaveRequests, Employees);
    });

    this.on('Reject', LeaveRequests, async (req) => {
        await rejectLeave(req, LeaveRequests);
    })

    this.on('Cancel', LeaveRequests, async (req) => {
        await cancelLeave(req, LeaveRequests);
    })

    this.after("READ", Employees, setEmployeeCriticality);

    this.after("READ", LeaveRequests, setLeaveRequestProperties);

});

async function validateEmployee(req, Employees) {
    const data = req.data;
    const tx = cds.tx(req);
    //validating the salary not - neg or zero
    if (req.event == 'CREATE' || req.event == 'UPDATE') {
        if (data.Salary <= 0) {
            req.reject(400, 'Salary must be greater than zero.');
        }
    }
    if ((req.event == 'UPDATE' || req.event == 'CREATE') && req.data.Salary >= 1000000) {
        req.reject(400, 'Salary is crossing the limit, please get the approval');
    }
    //assigning the default value
    if (!data.Status) {
        data.Status = 'Active';
    }
    //validating the employee no is unique - select * from Employeess where EmployeeNo = data.EmployeeNo
    //CREATE === 'CREATE'
    if (req.event === 'CREATE') {
        const existingEmployee = await tx.run(
            SELECT.one.from(Employees)//select * from Employees where EmployeeNo = data.EmployeeNo;
                .where({
                    EmployeeNo: data.EmployeeNo
                })
        );
        if (existingEmployee) {
            req.reject(
                400,
                'Employee Number ${data.EmployeeNo} already exists.'
            );
        }
    }
    // UPDATE  == UPDATE
    // if (req.event == 'UPDATE' && data.EmployeeNo) {
    //     req.reject(400, 'Updating Employee No is not possible, always Employee No must unqiue');
    // }

    //Email address normalization 
    if (data.Email) {
        data.Email = data.Email.toLowerCase().trim();
    }
    //Formating the Sting value using the helper function 
    if (data.FirstName) {
        data.FirstName = capitalize(data.FirstName);
    }
    if (data.LastName) {
        data.LastName = capitalize(data.LastName);
    }
    if (data.FullName) {
        data.FullName = capitalize(data.FullName);
    }


}



async function validateLeaveRequest(req, Employees, LeaveRequests) {

    const tx = cds.tx(req);

    const STATUS = {
        ACTIVE: "Active",
        INACTIVE: "Inactive",
        PENDING: "Pending",
        APPROVED: "Approved",
        REJECTED: "Rejected"
    };

    const employee = await tx.run(


        SELECT.one

            .from(Employees)

            .where({

                ID: req.data.Employee_ID

            })

    );

    if (!employee) {

        req.reject(

            404,

            "Employee not found."

        );

    }

    if (employee.Status !== STATUS.ACTIVE) {


        req.reject(

            400,

            "Inactive employees cannot apply for leave."

        );
    } else {
        await tx.run(
            INSERT.into(LeaveRequests).entries({
                LeaveID: req.data.LeaveID,
                FromDate: req.data.FromDate,
                ToDate: req.data.ToDate,
                Reason: req.data.Reason,
                Employee_ID: req.data.Employee_ID

            })
        )
    }

}

//Helper function 
function capitalize(text) {

    if (!text) {
        return text;
    }

    return text.charAt(0).toUpperCase() +
        text.slice(1).toLowerCase();

}

// async function approveLeave(req, LeaveRequests) {

//     const tx = cds.tx(req);

//     const leaveId = req.params[0].ID;
//     console.log(leaveId);
//     await tx.run(

//         UPDATE(LeaveRequests)

//             .set({

//                 Status: "Approved"

//             })

//             .where({

//                 Employee_ID: leaveId

//             })

//     );

//     return {

//         message: "Leave Request Approved Successfully."

//     };

// }

// async function approveLeave(req, LeaveRequests, Employees) {

//     const tx = cds.tx(req);

//     console.log("Request Params:", req.params);
//     console.log("Request Data:", req.data);

//     const leaveId = req.params[req.params.length - 1].ID;

//     //or
//     //const leaveId = req.params[1].ID;
//     console.log("Leave ID:", leaveId);

//     // Fetch Leave Request
//     const leaveRequest = await tx.run(
//         SELECT.one
//             .from(LeaveRequests)
//             .where({ ID: leaveId })
//     );

//     if (!leaveRequest) {
//         return req.reject(404, "Leave Request not found.");
//     }

//     // Fetch Employee associated with Leave Request
//     const employee = await tx.run(
//         SELECT.one
//             .from(Employees)
//             .where({ ID: leaveRequest.Employee_ID })
//     );

//     if (!employee) {
//         return req.reject(404, "Employee not found.");
//     }

//     // Validate Employee Status
//     if (employee.Status !== "Active") {
//         return req.reject(
//             400,
//             "Cannot approve leave. Employee is inactive."
//         );
//     }

//     // Update Leave Request
//     await tx.run(
//         UPDATE(LeaveRequests)
//             .set({
//                 Status: "Approved"
//             })
//             .where({
//                 ID: leaveId
//             })
//     );
//     req.notify("Leave Request Approved Successfully.");
//     return {
//         message: "Leave Request Approved Successfully."
//     };
// }
async function approveLeave(req, LeaveRequests, Employees) {

    const tx = cds.tx(req);

    console.log("Request Params:", req.params);
    console.log("Request Data:", req.data);

    const leaveId = req.params[req.params.length - 1].ID;

    //or
    //const leaveId = req.params[1].ID;
    console.log("Leave ID:", leaveId);

    // Fetch Leave Request
    const leaveRequest = await tx.run(
        SELECT.one
            .from(LeaveRequests)
            .where({ ID: leaveId })
    );

    if (!leaveRequest) {
        return req.reject(404, "Leave Request not found.");
    }

    // Fetch Employee associated with Leave Request
    const employee = await tx.run(
        SELECT.one
            .from(Employees)
            .where({ ID: leaveRequest.Employee_ID })
    );

    if (!employee) {
        return req.reject(404, "Employee not found.");
    }

    // Validate Employee Status
    if (employee.Status !== "Active") {
        return req.reject(
            400,
            "Cannot approve leave. Employee is inactive."
        );
    }

    // Update Leave Request
    await tx.run(
        UPDATE(LeaveRequests)
            .set({
                Status: "Approved"
            })
            .where({
                ID: leaveId
            })
    );
    req.notify("Leave Request Approved Successfully.");
    return {
        message: "Leave Request Approved Successfully."
    };
}

async function rejectLeave(req, LeaveRequests) {

    const tx = cds.tx(req);
    const leaveId = req.params[1].ID;

    const reason = req.data.reason;

    if (!reason) {
        return req.reject(400, "Rejection reason is required.");
    }

    await tx.run(
        UPDATE(LeaveRequests)
            .set({
                Status: "Rejected",
                Reason: reason
            })
            .where({
                ID: leaveId
            })
    );
    req.notify("Leave Request Rejected.");
    return {
        message: "Leave Request Rejected Successfully."
    };

}

async function cancelLeave(req, LeaveRequests) {

    const tx = cds.tx(req);
    const leaveId = req.params[1].ID;

    await tx.run(
        UPDATE(LeaveRequests)
            .set({
                Status: "Cancelled"
            })
            .where({
                ID: leaveId
            })
    );
    req.notify("Leave Request Cancelled.");
    return {
        message: "Leave Request Cancelled Successfully."
    };
}

async function getEmployeeCount(req) {

    const tx = cds.tx(req);

    const employees = await tx.run(

        SELECT.from("Employees")

    );

    return employees.length;

}

function setEmployeeCriticality(results) {

    if (!results) return;

    const employees = Array.isArray(results)
        ? results
        : [results];

    //  const employeeList = Array.isArray(results)
    //     ? results
    //     : results ? [results] : [];

    for (const employee of employees) {

        switch (employee.Status) {

            case "Active":
                employee.StatusCriticality = 3;
                employee.SalaryFieldControl = 3;

                employee.JoiningDateFieldControl = 3;

                break;

            case "Inactive":
                employee.StatusCriticality = 1;
                employee.SalaryFieldControl = 1;

                employee.JoiningDateFieldControl = 1;
                break;

            default:
                employee.StatusCriticality = 0;
                employee.SalaryFieldControl = 3;

                employee.JoiningDateFieldControl = 3;
        }

    }

}

function setLeaveRequestProperties(results) {

    if (!results) return;

    const leaveRequests = Array.isArray(results)
        ? results
        : [results];

    for (const leave of leaveRequests) {

        switch (leave.Status) {

            case "Pending":
                leave.StatusCriticality = 2;
                leave.CanApprove = true;
                break;

            case "Approved":
                leave.StatusCriticality = 3;
                leave.CanApprove = false;
                break;

            case "Rejected":
                leave.StatusCriticality = 1;
                leave.CanApprove = false;
                break;


            default:
                leave.StatusCriticality = 0;
                leave.CanApprove = false;
        }

    }

}

