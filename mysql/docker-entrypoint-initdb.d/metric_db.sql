CREATE DATABASE `metric_db`;
 
USE `metric_db`;

GRANT ALL ON metric_db.* TO 'metric_user'@'%' IDENTIFIED BY 'metricpwd';
FLUSH PRIVILEGES;

CREATE TABLE `host` (
    `hostip` VARCHAR(15),
    `hostname` VARCHAR(64),
    PRIMARY KEY (`hostname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `container` (
    `hostname` VARCHAR(64),
    `containername` VARCHAR(64),
    `type` VARCHAR(64),
    PRIMARY KEY (`containername`),
    INDEX (hostname),
    FOREIGN KEY (`hostname`) REFERENCES `host`(`hostname`) ON DELETE CASCADE
--    FOREIGN KEY (hostname) REFERENCES host(hostname)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `metric` (
    `containername` VARCHAR(64),
    `timestmp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `metrictype` VARCHAR(64),
    `value` DECIMAL(10),
    `unit` VARCHAR(64),
    PRIMARY KEY (`containername`, `metrictype`),
    INDEX (containername, metrictype),
    FOREIGN KEY (`containername`) REFERENCES `container`(`containername`) ON DELETE CASCADE
--    FOREIGN KEY (containername) REFERENCES container(containername)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
