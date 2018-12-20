drop table if exists `car`;

create table `car` (
  id int,
  name varchar(50),
  description json
);

insert into `car` values
  ( 
    1,
    'Alfa Romeo Giulia Quadrifoglio',
    '{ "color": "red",
       "doors": 4,
       "motor": {"cylinders": 6, "hp": 510, "torque": 600, "manufacturer": "Ferrari"}
     }'
  ),
  ( 
    2,
    'Porsche 911 GT3',
    '{ "color": "black",
       "doors": 2,
       "motor": {"cylinders": 6, "hp": 520, "torque": 470, "manufacturer": "Porsche"}
     }'
  ),
  ( 
    3,
    'Tesla Model S',
    '{ "color": "blue",
       "doors": 4,
       "motor": {"hp": 770, "torque": 1250, "manufacturer": "Tesla", "system": "AC Induction"},
       "battery": {"type": "lithium-ion", "capacity": 100}
     }'
  );