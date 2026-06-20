# Domain Ownership

Resident Module owns:

- Resident
- Household
- Occupancy

Finance Module owns:

- Bill
- Payment
- Ledger

Forum Module owns:

- Post
- Comment
- Reaction

Maps Module owns:

- HouseCoordinate
- FacilityLocation
- MapLayer

A module may read another module's data only through contracts.

A module may never directly access another module's repositories.
