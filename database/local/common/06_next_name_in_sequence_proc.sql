DROP FUNCTION IF EXISTS GetNumberInName;

delimiter $$

CREATE FUNCTION `GetNumberInName`(sNameParam VARCHAR(255) CHARACTER SET utf8, sPrefixParam VARCHAR(100)) RETURNS int(11)
    NO SQL
    DETERMINISTIC
BEGIN
	DECLARE nLastNumber int DEFAULT 0;
	
	DECLARE nCtr int DEFAULT 0;
	DECLARE nDigitCount INT DEFAULT 0;
	DECLARE nDigit INT DEFAULT 0;
	DECLARE sChar VARCHAR(1);
	DECLARE sName VARCHAR(255);
	DECLARE bIsNumber BOOLEAN DEFAULT FALSE;
	
	SET sName = REPLACE(sNameParam, sPrefixParam, ''); -- delete the prefix from name
	SET nCtr = LENGTH(sName);
	
	-- iterate the name backwards to build number part
	WHILE nCtr > 0 DO 
		SET sChar = SUBSTRING(sName, nCtr, 1);
		SET bIsNumber = sChar REGEXP('[0-9]');
		IF bIsNumber = true THEN
			SET nDigit = CONVERT(sChar,UNSIGNED INTEGER);
			SET nLastNumber = nLastNumber + (nDigit * pow(10, nDigitCount));
			SET nDigitCount = nDigitCount + 1;
		ELSE
			SET nDigitCount = 0;
			SET nLastNumber = 0;
		END IF;

		SET nCtr = nCtr - 1;
	END WHILE;
 
	
RETURN nLastNumber;
END$$

delimiter ;