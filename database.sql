CREATE DATABASE IF NOT EXISTS `FIT` DEFAULT CHARACTER SET utf8 COLLATE utf8_czech_ci;
USE `FIT`;

CREATE TABLE `SubjectDefs` (
	`Name` VARCHAR(10) COLLATE utf8_czech_ci NOT NULL,
    `Credits` INT NOT NULL,
    `Type` ENUM('P', 'PV', 'V') COLLATE utf8_czech_ci NOT NULL,
    `FinishType` ENUM('Zk', 'ZaZk', 'Za', 'KlZa') COLLATE utf8_czech_ci NOT NULL DEFAULT 'ZaZk'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

CREATE TABLE `Subjects` (
	`Subject` VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_czech_ci NOT NULL,
    `Points` INT NOT NULL,
    `Done` TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

INSERT INTO `SubjectDefs` (`Name`, `Credits`, `Type`, `FinishType`) VALUES ('BAN2', 3, 'PV', 'ZaZk'), ('BAN3', 3, 'PV', 'ZaZk'), ('BAN4', 3, 'PV', 'ZaZk'), ('IAL', 5, 'P', 'ZaZk'),
('IBT', 13, 'P', 'Za'), ('ICS', 4, 'PV', 'KlZa'), ('IDA', 7, 'P', 'Zk'), ('IDS', 5, 'P', 'ZaZk'), ('IEL', 6, 'P', 'ZaZk'), ('IFJ', 5, 'P', 'ZaZk'), ('IIS', 4, 'P', 'ZaZk'),
('IMA', 6, 'P', 'Zk'), ('IMP', 6, 'P', 'ZaZk'), ('IMS', 5, 'P', 'ZaZk'), ('INC', 5, 'P', 'ZaZk'), ('INM', 5, 'P', 'ZaZk'), ('INP', 6, 'P', 'ZaZk'), ('IOS', 5, 'P', 'ZaZk'),
('IPK', 4, 'P', 'ZaZk'), ('IPP', 5, 'P', 'ZaZk'), ('ISA', 5, 'P', 'ZaZk'), ('ISM', 2, 'V', 'Za'), ('ISS', 6, 'P', 'Zk'), ('ISU', 6, 'P', 'ZaZk'), ('ITT', 5, 'P', 'Za'), 
('ITU', 5, 'P', 'KlZa'), ('ITY', 4, 'V', 'ZaZk'), ('IUS', 5, 'P', 'ZaZk'), ('IVS', 5, 'V', 'ZaZk'), ('IW1', 5, 'V', 'ZaZk'), ('IW2', 5, 'V', 'ZaZk'), ('IW5', 5, 'V', 'ZaZk'),
('IZG', 6, 'P', 'ZaZk'), ('IZP', 7, 'P', 'ZaZk'), ('IZU', 4, 'P', 'ZaZk');

INSERT INTO `Subjects` (`Subject`, `Points`, `Done`) VALUES ('BAN2', 0, 0), ('BAN3', 0, 0), ('BAN4', 0, 0), ('IAL', 0, 0), ('IBT', 0, 0), ('ICS', 0, 0), ('IDA', 0, 0), ('IDS', 0, 0),
('IEL', 0, 0), ('IFJ', 0, 0), ('IIS', 0, 0), ('IMA', 0, 0), ('IMP', 0, 0), ('IMS', 0, 0), ('INC', 0, 0), ('INM', 0, 0), ('INP', 0, 0), ('IOS', 0, 0), ('IPK', 0, 0), ('IPP', 0, 0),
('ISA', 0, 0), ('ISM', 0, 0), ('ISS', 0, 0), ('ISU', 0, 0), ('ITT', 0, 0), ('ITU', 0, 0), ('ITY', 0, 0), ('IUS', 0, 0), ('IVS', 0, 0), ('IW1', 0, 0), ('IW2', 0, 0), ('IW5', 0, 0),
('IZG', 0, 0), ('IZP', 0, 0), ('IZU', 0, 0);

ALTER TABLE `SubjectDefs` ADD PRIMARY KEY (`Name`);
ALTER TABLE `Subjects` ADD PRIMARY KEY (`Subject`);
ALTER TABLE `Subjects` ADD CONSTRAINT `SubjectConstraint` FOREIGN KEY (`Subject`) REFERENCES `SubjectDefs` (`Name`) ON DELETE CASCADE  ON UPDATE CASCADE;

CREATE VIEW `Credits` AS SELECT
	SUM(`sd`.`Credits`) AS `Total`,
    SUM(IF(`s`.`Done` = 1, `sd`.`Credits`, 0)) AS `Achieved`,
    (SUM(`sd`.`Credits`) - SUM(IF(`s`.`Done` = 1, `sd`.`Credits`, 0))) AS `Left`
FROM `SubjectDefs` `sd` JOIN `Subjects` `s` ON (`s`.`Subject` = `sd`.`Name`);

CREATE VIEW `Grades` AS SELECT
	IF(`sd`.`FinishType` = 'Za', '-',
       	IF(`s`.`Points` >= 49.5 AND `s`.`Points` <= 59, 'E',
           IF(`s`.`Points` >= 59.5 AND `s`.`Points` <= 69, 'D',
              IF(`s`.`Points` >= 69.5 AND `s`.`Points` <= 79, 'C',
                 IF(`s`.`Points` >= 79.5 AND `s`.`Points` <= 89, 'B',
                    IF(`s`.`Points` >= 89.5, 'A',
                       IF(`s`.`Points` > 0 AND `s`.`Points` <= 49.5, 'F', 'N')
                    )
                 )
              )
           )
        )
    ) AS `Grade`,
    COUNT(0) AS `Count`,
    SUM(`sd`.`Credits`) AS `Credits`
FROM `Subjects` `s` JOIN `SubjectDefs` `sd` ON (`sd`.`Name` = `s`.`Subject`)
GROUP BY `Grade`
ORDER BY `Grade` ASC;

CREATE VIEW `Points` AS SELECT
	COUNT(0) * 100 AS `Total`,
    SUM(`s`.`Points`) AS `Achieved`,
    ((Count(0) * 100) - SUM(`s`.`Points`)) AS `Left`,
    (((COUNT(0) - (SELECT COUNT(0) FROM `Subjects` `s1` WHERE `s1`.`Points` = 0)) * 100) - SUM(`s`.`Points`)) AS `Lost`
FROM `SubjectDefs` `sd` JOIN `Subjects` `s` ON (`s`.`Subject` = `sd`.`Name`);

CREATE VIEW `Results` AS SELECT 
    `s`.`Subject` AS `Subject`,
    `s`.`Points` AS `Points`,
    if(`s`.`Points` < 50, 50 - `s`.`Points`, '-') AS `Points to E`,
    if(`s`.`Points` < 60, 60 - `s`.`Points`, '-') AS `Points to D`,
    if(`s`.`Points` < 70, 70 - `s`.`Points`, '-') AS `Points to C`,
    if(`s`.`Points` < 80, 80 - `s`.`Points`, '-') AS `Points to B`,
    if(`s`.`Points` < 90, 90 - `s`.`Points`, '-') AS `Points to A`,
    if(`s`.`Done` = 1, `sd`.`Credits`, 0) AS `Credits`,
    if(`sd`.`FinishType` = 'Za', '-', 
        if((`s`.`Points` >= 49.5) and (`s`.`Points` <= 59), 'E',
            if((`s`.`Points` >= 59.5) and (`s`.`Points` <= 69), 'D',
                if((`s`.`Points` >= 69.5) and (`s`.`Points` <= 79), 'C',
                    if((`s`.`Points` >= 79.5) and (`s`.`Points` <= 89),'B',
                        if(`s`.`Points` >= 89.5,'A',
                            if((`s`.`Points` > 0) and (`s`.`Points` <= 49.5),'F','N')
                        )
                    )
                )
            )
        )
    ) AS `Grade`,
    `sd`.`Type` AS `Type`,
    `sd`.`FinishType` AS `Finish type`
FROM `Subjects` `s` join `SubjectDefs` `sd` on `sd`.`Name` = `s`.`Subject`
ORDER BY `s`.`Subject` ASC;

CREATE VIEW `SubjectsCount` AS SELECT 
    COUNT(0) AS `Total`,
    SUM(if(`s`.`Done` = 1, 1, 0)) AS `Done`,
    (COUNT(0) - SUM(if(`s`.`Done` = 1, 1, 0))) AS `Left`
FROM `SubjectDefs` `sd` join `Subjects` `s` on `s`.`Subject` = `sd`.`Name`;
