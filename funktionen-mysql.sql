-- AUTHOR: Markus Reichl
-- VERSION: 24.10.2017

-- Übung: Funktion mit 2 Parametern
-- Erstelle eine Funktion mit zwei Parametern: Alle Speisen die billiger als der Durchschnittspreis aller Speisen sind, sollen um einen fixen Betrag erhöht werden, alle Speisen die teurer sind, sollen um einen Prozentwert erhöht werden. 
DELIMITER //
DROP PROCEDURE IF EXISTS preisavg;
CREATE PROCEDURE preisavg()
BEGIN
	SELECT avg(preis) FROM speise;
END;//
DELIMITER ;

CALL preisavg;

DELIMITER //
DROP PROCEDURE IF EXISTS preiserhoehung;
CREATE PROCEDURE preiserhoehung(IN add_value INTEGER, IN multiply_value INTEGER)
BEGIN
	UPDATE speise SET preis = preis + value WHERE preis < preisavg();
	UPDATE speise SET preis = preis * (100 + multiply_value) / 100 WHERE preis >= preisavg();
END;//
DELIMITER ;

CALL preiserhoehung(1, 2);

-- Übung: Tagesumsatz
-- Der Tagesumsatz für einen bestimmten Kellner soll für den aktuellen Tag ermittelt werden (Kellner-Nr via Parameter, aktueller Tag via CURRENT_DATE).

-- RÜCKGABEWERTE
-- Möglichkeiten:
-- 1) SELECT    SUM(), AVG(), MAX(), MIN(), COUNT()
-- 2) SELECT    17 + 4;
-- 3) SELECT    spalte LIMIT 1;

-- Kellner Umsatz
DELIMITER //
DROP PROCEDURE IF EXISTS kellnerumsatz;
CREATE PROCEDURE kellnerumsatz(IN kellner_id INTEGER, OUT umsatz NUMERIC)
BEGIN
	SELECT SUM(speise.preis*bestellung.anzahl)
	FROM speise, rechnung, bestellung
	WHERE speise.snr=bestellung.snr
	AND rechnung.rnr=bestellung.rnr
	AND rechnung.knr=kellner_id
	AND rechnung.status='bezahlt';
END;//
DELIMITER ;

CALL kellnerumsatz(1, @umsatz);

-- MWST
DELIMITER //
DROP PROCEDURE IF EXISTS preisBrutto;
CREATE PROCEDURE preisBrutto(IN speise_snr INTEGER, OUT preis_brutto DECIMAL(4, 2))
BEGIN
	SELECT speise.preis * 1.2 FROM speise WHERE speise.snr = speise_snr;
END;//
DELIMITER ;

CALL preisBrutto(1, @preis_brutto);

DELIMITER //
DROP PROCEDURE IF EXISTS preisMwst;
CREATE PROCEDURE preisMwst(IN speise_snr INTEGER, OUT preis_brutto DECIMAL(4, 2))
BEGIN
	SELECT speise.preis * 0.2 FROM speise WHERE speise.snr = speise_snr;
END;//
DELIMITER ;

CALL preisMwst(1, @mwst);

-- TODO: Auf alle Speisen anwenden
-- SELECT bezeichnung, CALL preisBrutto(speise.*, @preis_brutto) as "Brutto", CALL preisMwst(speise.*, @mwst) as "Mwst." FROM speise;

-- Übung: Nie bestellte Speisen
-- Übung:
-- Erstelle eine weitere Funktion zur Berechnung der MWSt. Zeige von allen Speisen den
-- Brutto-Preis als Brutto und die darin enthaltene MWSt. als Spalte MWSt an.
-- Zusatz: Die Anzeige bei Brutto/MWSt soll auf zwei Nachkommastellen beschränkt werden.

DELIMITER //
DROP PROCEDURE IF EXISTS nieBestellteSpeisen;
CREATE PROCEDURE nieBestellteSpeisen() 
BEGIN
	SELECT speise.bezeichnung AS "Bezeichnung", speise.preis AS "Nettopreis"
	FROM speise
	WHERE speise.snr NOT IN (SELECT snr FROM bestellung);
END//
DELIMITER ;

CALL nieBestellteSpeisen();

SELECT * FROM nieBestellteSpeisen();
