CREATE DATABASE IF NOT EXISTS AppianPrimaryDS default character set = "UTF8" default collate = "utf8_general_ci";
CREATE DATABASE IF NOT EXISTS AppianBusinessDS default character set = "UTF8" default collate = "utf8_general_ci";

CREATE USER IF NOT EXISTS 'appian'@'%' IDENTIFIED BY 'appian';
CREATE USER IF NOT EXISTS 'appian'@'localhost' IDENTIFIED BY 'appian';

GRANT ALL ON *.* TO 'appian'@'%' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'appian'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;
