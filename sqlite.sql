
--delete from User;
--delete from UserProfile;
--delete from LocationLog;
--delete from ProcessedLocation;

select * from User;
select * from UserProfile
select * from LocationLog;
select * from ProcessedLocation;

select distinct(userId), count(*) as count
from LocationLog
group by userId
order by count(*) desc;

SELECT 
	UserProfile.name,
	DATETIME(UserProfile.locationUpdatedAt, 'unixepoch') as locationUpdatedAt
FROM User, UserProfile
WHERE User.objectId = UserProfile.userId

SELECT 
	UserProfile.name,
	ProcessedLocation.timePeriod,
	DATETIME(ProcessedLocation.updated, 'unixepoch') as locationUpdatedAt
FROM UserProfile, ProcessedLocation
WHERE UserProfile.userId = ProcessedLocation.userId;

SELECT
	User.objectId,
	LocationLog.latitude,
	LocationLog.longitude,
	LocationLog.speed,
	LocationLog.altitude,
	DATETIME(LocationLog.created, 'unixepoch') as created,
	DATETIME(LocationLog.updated, 'unixepoch') as updated
FROM LocationLog, User
WHERE 
	LocationLog.userId = User.objectId AND 
	User.objectId = 'tQlzULE6Md' AND 
	DATE(LocationLog.created, 'unixepoch') > DATE('now','localtime','-1 days')
ORDER BY created DESC

SELECT
	User.username,
	UserProfile.name,
	User.facebookId,
	User.timeZone,
	LocationLog.latitude,
	LocationLog.longitude,
	LocationLog.speed,
	LocationLog.altitude,
	DATETIME(LocationLog.created, 'unixepoch') as created,
	DATETIME(LocationLog.updated, 'unixepoch') as updated
FROM LocationLog, User, UserProfile
WHERE 
	LocationLog.userId = User.objectId AND 
	User.objectId = UserProfile.userId AND 
	User.objectId = 'tQlzULE6Md' AND
	DATE(LocationLog.created, 'unixepoch') > DATE('now','localtime','-14 days')
ORDER BY LocationLog.created DESC
LIMIT 1000;

SELECT
	objectId,
	username,
	facebookId,
	timeZone,
	DATETIME(created, 'unixepoch') as created,
	DATETIME(updated, 'unixepoch') as updated
FROM User
WHERE objectId = 'AWUB43Ia3C'

AWUB43Ia3C,572


SELECT * FROM User where objectId like 'F%';


delete from user;
delete from locationlog;

SELECT
	objectId,
	userId,
	latitude,
	longitude,
	speed,
	altitude,
	datetime(created, 'unixepoch') as created,
	datetime(updated, 'unixepoch') as updated
FROM LocationLog
ORDER BY created DESC;

SELECT tastings.* FROM tastings   
WHERE (DATE(tastings.date) > DATE('now','weekday 1','+ 7 days'))

SELECT DATE('now','weekday 1','+ 7 days')

SELECT DATE('now')

SELECT DATETIME('now')

SELECT strftime('%W','now')

SELECT strftime('%d','now')

SELECT strftime('%m','now')

SELECT DATE('now','localtime','-1 days')
