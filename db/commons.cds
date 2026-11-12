namespace ems.db;

type Guid : String(20);//resuable type

aspect address {
    HouseNo : String(10);
    Landmark : String(20);
    Area : String(20);
    City : String(20);
    Country : String(10)
}