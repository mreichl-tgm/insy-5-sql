-- :: Au09a ::
-- AUTHOR: Markus Reichl
-- VERSION: 2018-04-19
CREATE FUNCTION update_rechnung() RETURNS trigger AS $update_rechnung$
    BEGIN
        IF NEW.datum IS NULL THEN
			NEW.datum := current_date;
		END IF;
        RETURN NEW;
    END;
$update_rechnung$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_rechnung BEFORE INSERT ON rechnung 
	FOR EACH ROW EXECUTE PROCEDURE update_rechnung();

INSERT INTO rechnung VALUES(7, NULL, 2, 'offen', 2);
SELECT * FROM rechnung;


-- :: Au09b ::
-- AUTHOR: Markus Reichl
-- VERSION: 2018-04-19
CREATE TABLE preis (
	snr     INTEGER,
    datum   DATE,
    diff	DECIMAL(6,2),
    PRIMARY KEY (snr, datum),
	FOREIGN KEY (snr) REFERENCES speise (snr) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE FUNCTION insert_preis() RETURNS trigger AS $insert_preis$
    BEGIN
        IF NEW.preis <> OLD.preis THEN
			INSERT INTO preis VALUES(NEW.snr, CURRENT_DATE, NEW.preis - OLD.preis);
		END IF;
        RETURN NEW;
    END;
$insert_preis$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_preis BEFORE UPDATE ON speise 
    FOR EACH ROW EXECUTE PROCEDURE insert_preis();

UPDATE speise SET preis = 24 WHERE snr = 8;
SELECT * FROM preis;

-- :: Au09c ::
-- AUTHOR: Markus Reichl
-- VERSION: 2018-04-19
CREATE TABLE storno (
	scount      SMALLINT,
    rnr         INTEGER,
    snr         INTEGER,
    PRIMARY KEY (rnr, snr),
    FOREIGN KEY (rnr) REFERENCES rechnung (rnr) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (snr) REFERENCES speise (snr) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE FUNCTION insert_storno() RETURNS trigger AS $insert_storno$
    BEGIN
        INSERT INTO storno VALUES (OLD.scount, OLD.rnr, OLD.snr);
		RETURN NEW;
    END;
$insert_storno$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_storno BEFORE DELETE ON bestellung 
    FOR EACH ROW EXECUTE PROCEDURE insert_storno();

DELETE FROM bestellung WHERE rnr = 1 AND snr = 1;
SELECT * FROM storno;


-- :: Au09d ::
-- AUTHOR: Markus Reichl
-- VERSION: 2018-04-19
CREATE TABLE stats (
	sdate       DATE,
    scount      INTEGER,
    PRIMARY KEY (sdate)
);

CREATE FUNCTION insert_stats() RETURNS trigger AS $insert_stats$
    BEGIN
        IF (SELECT COUNT(datum) FROM stats WHERE sdate = CURRENT_DATE) = 0 THEN
			INSERT INTO stats VALUES (CURRENT_DATE, (SELECT COUNT(snr) FROM speise));
		ELSE
			UPDATE stats SET scount = (SELECT COUNT(snr) FROM speise) WHERE sdate = CURRENT_DATE;
		END IF;
		RETURN NEW;
    END;
$insert_stats$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_stats AFTER INSERT OR DELETE ON speise 
    FOR EACH ROW EXECUTE PROCEDURE insert_stats();

-- Test data
INSERT INTO speise VALUES (9, 'Menue fuer 5', 65);
INSERT INTO speise VALUES (10, 'Menue fuer 6', 31);
SELECT * FROM stats;

DELETE FROM speise WHERE snr = 9;
SELECT * FROM stats;
