--	Eliminamos la BD si existe
DROP DATABASE IF EXISTS practice;

--	Creamos la BD
CREATE DATABASE practice;

--	Nos conectamos a la BD
\c practice;

CREATE TABLE IF NOT EXISTS userRegister(
  userId INT PRIMARY KEY,
  userName VARCHAR(16),
  phoneNumber SMALLINT
);

CREATE TABLE IF NOT EXISTS userActions(
  userId INT,
  FOREIGN KEY (userId) REFERENCES userRegister(userId),
  actionDate DATE,
  userAction VARCHAR(16),
  PRIMARY KEY (userId,actionDate,userAction)
);

INSERT INTO userRegister(userId,userName,phoneNumber) VALUES (1,'Juan',0414);
INSERT INTO userRegister(userId,userName,phoneNumber) VALUES (2,'Pedro',0416);
INSERT INTO userRegister(userId,userName,phoneNumber) VALUES (3,'Luis',0426);

SELECT * FROM userRegister;

INSERT INTO userActions(userId,actionDate,userAction) VALUES (1,'1999-9-9','In');
INSERT INTO userActions(userId,actionDate,userAction) VALUES (2,'1999-9-9','Out');
INSERT INTO userActions(userId,actionDate,userAction) VALUES (3,'1999-9-9','Out');
SELECT * FROM userActions;

SELECT R.userName,A.actionDate, A.userAction
FROM userRegister AS R
NATURAL JOIN userActions AS A;

with recursive cte 
as 
(
  SELECT 1  AS seq, 1 AS val
  UNION ALL
  SELECT seq + 1, val*(seq+1) FROM cte WHERE seq < 10
)

select * from cte