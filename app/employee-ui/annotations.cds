using EmployeeService as service from '../../srv/service';

annotate service.Employees with @(
    UI.HeaderInfo                : {
        TypeName      : 'Employee',
        TypeNamePlural: 'Employees',
        Title         : {
            $Type: 'UI.DataField',
            Value: FullName
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: EmployeeNo
        }
    },
    UI.DataPoint #EmployeeStatus : {
        Title      : 'Employee Status',
        Value      : Status,
        Criticality: StatusCriticality
    },
    UI.FieldGroup #GeneratedGroup: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'HouseNo',
                Value: HouseNo,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Landmark',
                Value: Landmark,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Area',
                Value: Area,
            },
            {
                $Type: 'UI.DataField',
                Label: 'City',
                Value: City,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Country',
                Value: Country,
            },
            {
                $Type: 'UI.DataField',
                Label: 'EmployeeNo',
                Value: EmployeeNo,
            },
            {
                $Type: 'UI.DataField',
                Label: 'FirstName',
                Value: FirstName,
            },
            {
                $Type: 'UI.DataField',
                Label: 'LastName',
                Value: LastName,
            },
            {
                $Type: 'UI.DataField',
                Label: 'FullName',
                Value: FullName,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Email',
                Value: Email,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Phone',
                Value: Phone,
            },
            {
                $Type                  : 'UI.DataField',
                Label                  : 'JoiningDate',
                Value                  : JoiningDate,
                ![@Common.FieldControl]: JoiningDateFieldControl
            },
            {
                $Type                  : 'UI.DataField',
                Label                  : 'Salary',
                Value                  : Salary,
                ![@Common.FieldControl]: SalaryFieldControl
            },
            {
                $Type      : 'UI.DataField',
                Label      : 'Status',
                Value      : Status,
                Criticality: StatusCriticality
            },
            {
                $Type: 'UI.DataField',
                Label: 'Department',
                Value: Department.DepartmentName
            }
        ],
    },
    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneratedFacet1',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'LeaveRequests',
            Label : 'Leave Requests',
            Target: 'LeaveRequests/@UI.LineItem'
        },
        {
            $Type               : 'UI.ReferenceFacet',
            ID                  : 'EmployeeStatusHeader',
            Label               : 'Status',
            Target              : '@UI.DataPoint#EmployeeStatus',
            ![@UI.PartOfPreview]: true
        },
    ],
    UI.LineItem                  : [
        {
            $Type            : 'UI.DataField',
            Label            : 'Employee No',
            Value            : EmployeeNo,
            ![@UI.Importance]: #High
        },
        {
            $Type: 'UI.DataField',
            Label: 'First Name',
            Value: FirstName,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Last Name',
            Value: LastName,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Email',
            Value: Email,
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Status',
            Value      : Status,
            Criticality: StatusCriticality
        },
        {
            $Type                  : 'UI.DataField',
            Label                  : 'JoiningDate',
            Value                  : JoiningDate,
            ![@Common.FieldControl]: JoiningDateFieldControl
        },
        {
            $Type                  : 'UI.DataField',
            Label                  : 'Salary',
            Value                  : Salary,
            ![@Common.FieldControl]: SalaryFieldControl
        }

    ],

    UI.SelectionFields           : [

        EmployeeNo,

        FirstName,

        Status,

        Department_ID

    ],
);

annotate service.Employees with {
    Department @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Departments',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: Department_ID,
                ValueListProperty: 'ID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'DepartmentID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'DepartmentName',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'Location',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'ManagerName',
            },
        ],
    }
};

annotate service.LeaveRequests with @(

UI.LineItem: [

    {
        $Type: 'UI.DataField',
        Value: FromDate
    },

    {
        $Type: 'UI.DataField',
        Value: ToDate
    },

    {
        $Type: 'UI.DataField',
        Value: Reason
    },

    {
        $Type      : 'UI.DataField',
        Value      : Status,
        Criticality: StatusCriticality
    },
    //approve leave
    {
        $Type             : 'UI.DataFieldForAction',
        Action            : 'EmployeeService.ApproveLeave',
        Label             : 'Approve',
        OperationAvailable: {$Path: 'CanApprove'}
    },
    // Reject Button
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'EmployeeService.Reject',
        Label : 'Reject'
    },

    // Cancel Button
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'EmployeeService.Cancel',
        Label : 'Cancel'
    }


]);

annotate service.Employees with {
    Salary      @Common.FieldControl: SalaryFieldControl;
    JoiningDate @Common.FieldControl: JoiningDateFieldControl;
};
