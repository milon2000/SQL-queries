-- CREATE DATABASE Firma_Turystyczna;
-- DROP DATABASE Firma_Turystyczna;

IF OBJECT_ID('Wycieczki','U') IS NOT NULL
    DROP TABLE Wycieczki
GO
CREATE TABLE Wycieczki (
	NazwaWycieczki NVARCHAR(50) PRIMARY KEY NOT NULL,
	Dostępność BIT NOT NULL,
	Cena$ MONEY NOT NULL,
	GodzinaRozpoczęcia TIME NOT NULL CHECK (GodzinaRozpoczęcia > '07:00:00'),
	IlośćMiejsc INT NOT NULL CHECK (IlośćMiejsc < 20)
)

IF OBJECT_ID('Klienci','U') IS NOT NULL
	DROP TABLE Klienci
GO
CREATE TABLE Klienci (
	ID_klienta INT PRIMARY KEY,
	ImieNazwisko NVARCHAR(50) NOT NULL,
	Adres NVARCHAR(50) NOT NULL,
	Tel NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	NIP NVARCHAR(50) NULL
)

IF OBJECT_ID('Dodatki','U') IS NOT NULL
    DROP TABLE Dodatki
GO
CREATE TABLE Dodatki
(
    NazwaDodatku NVARCHAR(50) PRIMARY KEY NOT NULL,
    Cena$ MONEY NOT NULL
)

INSERT INTO Wycieczki (NazwaWycieczki, Dostępność, Cena$, GodzinaRozpoczęcia, IlośćMiejsc)
VALUES ('Południowe Wybrzeże', 1, 120, '08:30:00', 19),
('Złoty Krąg', 1, 80, '09:00:00', 19),
('Polowanie na zorzę polarną', 1, 90, '20:30:00', 19),
('Półwysep Snaefellsens', 1, 120, '08:00:00', 19),
('Trekking po wulkanie', 1, 90, '10:00:00', 16),
('Snorkeling', 0, 120, '10:00:00', 6)

INSERT INTO Klienci (ID_klienta, ImieNazwisko, Adres, Tel, Email, NIP)
VALUES (1, 'George Smith', 'NY, US', '00123456789', 'g.smith@gmail.com', '1234567890'),
(2, 'John Doe', 'LA, US', '001987654321', 'j.doe@gmail.com', '987654321'),
(3, 'Jane Ian', 'NY, US', '001987654321', 'jane@gmail', '78956789'),
(4, 'Chris Mabel', 'LO, US', '00123456789', 'c.mabel@gmail.com', '43729823794'),
(5, 'Margret Sample', 'TX, US', '123456789', 'm.sample@gmail.com', '0734894499'),
(6, 'Denzel Washington', 'LA, US', '001987654321', 'd.washington@gmail.com', '2348657'),
(7, 'Ahmed Muhammad', 'Al Shahyia 22, 220 Dubai, Arab Emirates', '002123456789', 'a.muh@gmail.com', '898732211'),
(8, 'Your Day Tours', 'Borgatun 32, 101 Reykjavik','9807654', 'accounting@daytours.is', '4567879087'),
(9, 'Arctic Adventures', 'Skipholt 11, 110 Reykjavik','1807654', 'accounting@adventure.is', '5643781243'),
(10, 'Icelandic Mountain Guides', 'Hverfisgata 12, 101 Reykjavik','5807654', 'accounting@mountainguides.is', '220076-7876'),
(11, 'American Travel Agency', 'Long st., 324 Austin, Texas, US','001450968540', 'info@americantravel.com', '7890348479'),
(12, 'Pordróże bez Granic', 'Długa 32, 43-546 Kraków, Polska', '0048546743123', 'podroze.bez.granic@podroze.pl', '5467788900')

INSERT INTO Dodatki
    (NazwaDodatku, Cena$)
VALUES
    ('Buty trekkingowe', 10),
    ('Obsługa fotograficzna', 50),
    ('Kurtka p-deszczowa', 10),
    ('Spodnie p-deszczowe', 10),
    ('Fotelik dziecięcy', 10),
    ('Booster', 10),
    ('Przejażdżka konno', 150),
    ('Skutery śnieżne', 150),
    ('Quady', 150),
    ('Wstęp do spa', 80)

--------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Mila -----------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Zamówienia ','U') IS NOT NULL
    DROP TABLE Zamówienia
GO
CREATE TABLE Zamówienia13
(
    ID_zamówienia INT NOT NULL,
    DataZamówienia DATE DEFAULT NULL,
    NazwaWycieczki NVARCHAR(50) NULL FOREIGN KEY REFERENCES Wycieczki(NazwaWycieczki),
    IlośćOsób_NaWycieczce INT NOT NULL,
    NazwaDodatku NVARCHAR(50) NULL FOREIGN KEY REFERENCES Dodatki(NazwaDodatku),
    IlośćDodatków INT NOT NULL,
    CenaWycieczki INT NOT NULL,
    CenaDodatku INT NOT NULL,
    ID_klienta INT FOREIGN KEY REFERENCES Klienci(ID_klienta),
    ID_pracownika INT FOREIGN KEY REFERENCES Pracownicy(ID_pracownika),
    CONSTRAINT IlośćDodatków
    CHECK (IlośćDodatków <= IlośćOsób_NaWycieczce)
)

-- ilosc dodatkow nie moe byc wieksza niz ilosc osob

INSERT INTO Zamówienia
    (IdZamówienia, DataZamówienia, NazwaWycieczki, IlośćWycieczek, NazwaDodatku, IlośćDodatków, CenaWycieczki, CenaDodatku, IdKlienta, IdPracownika)
VALUES
    (54321, '2023-01-13', 'Południowe Wybrzeże', 2, 'Obsługa fotograficzna', 2, 120, 50, 1, 12345),
    (54321, '2023-01-13', null, 0, 'Fotelik dziecięcy', 1, 0, 10, 1, 12345),
    (64321, '2023-01-15', 'Złoty Krąg', 3, 'Booster', 4, 0, 10, 2, 22345),
    (74321, '2023-01-10', 'Złoty Krąg', 2 , 'Wstęp do spa', 2, 80, 80, 6, 32345),
    (84321, '2022-12-15', 'Złoty Krąg', 3, 'Przejażdżka konno', 1, 80, 150, 7, 42345),
    (94321, '2022-10-11', 'Polowanie na zorzę polarną', 1, 'Skutery śnieżne', 2, 90, 150, 3, 52345),
    (94321, '2022-10-11', null, 0, 'Buty trekkingowe', 2, 0, 10, 3, 52345),
    (104321, '2022-10-11', 'Półwysep Snaefellsens', 2, null, 0, 120, 0, 4, 12345),
    (114321, '2022-11-12', 'Trekking po wulkanie', 5, null, 0, 90, 0, 5, 12345)

IF OBJECT_ID('Pracownicy','U') IS NOT NULL
    DROP TABLE Pracownicy
GO
CREATE TABLE Pracownicy
(
    ID_pracownika INT PRIMARY KEY,
    ImieNazwisko NVARCHAR(50) NOT NULL,
    Stanowisko NVARCHAR(100) NOT NULL,
    DataZatrudnienia DATETIME NULL,
    Tel NVARCHAR(25) NULL,
    Email NVARCHAR(50) NULL,
    Adres NVARCHAR(50) NULL
)

INSERT INTO Pracownicy
    (ID_pracownika, ImieNazwisko, Stanowisko, DataZatrudnienia, Tel, Email, Adres)
VALUES
    (12345, 'Unshimi Krodande', 'Pilot', '2013-05-06', 556604, 'unshimi@gmail.com', 'Storens vei 13, Kongsberg'),
    (22345, 'Elidvu Bhiulnu', 'Przewodnik', '2010-10-01', 666606, 'elidvu@gmail.com', 'Eidstoppen 16, Hof'),
    (32345, 'Nadendi Niesa', 'Przewodnik', '2011-02-01', 766707, 'nadendi@gmail.com', 'Roaveienn 20, Hokksund'),
    (42345, 'Ghairrakh Bhegeruh', 'Pilot', '2012-03-01', 866707, 'ghairrakh@gmail.com', 'Solhoyveine 20, Holmestrand'),
    (52345, 'Bhepiksho Zibir', 'Sekretarz', '2009-08-06', 962747, 'bhepiksho@gmail.com', 'Markveien 2, Kongsberg'),
    (62345, 'Rhihoco Ralnud', 'Pilot', '2001-02-06', 161717, 'rhihoco@gmail.com', 'Funkelia 18, Kongsberg' )

IF OBJECT_ID('Refundacje ','U') IS NOT NULL
    DROP TABLE Refundacje
GO

CREATE TABLE RefundacjeWycieczek
(
    IdRefundacji INT PRIMARY KEY,
    IdZamówienia INT REFERENCES Zamówienia (IdZamówienia),
    DataRefundacji DATE NOT NULL,
    DataWycieczki DATE NOT NULL,
    CONSTRAINT DataRefundacji
    CHECK (DataRefundacji < DataWycieczki)
)

INSERT INTO RefundacjeWycieczek
    (IdRefundacji, IdZamówienia, DataRefundacji, DataWycieczki)
VALUES
    (12355, 94321, '2022-10-20', '2023-02-10')


IF OBJECT_ID('Hotele ','U') IS NOT NULL
    DROP TABLE Hotele
GO
CREATE TABLE Hotele
(
    Nazwa NVARCHAR(50) PRIMARY KEY NOT NULL,
    Adres NVARCHAR(200) NULL,
)



INSERT INTO Hotele
    (Nazwa, Adres)
VALUES
    ('Hotel Skuggi', 'Hverfisgata 95'),
    ('Hilton Nordica', 'Sudurlandsbraut 1'),
    ('Centerhotel Plaza', 'Sudurlandsbraut 1'),
    ('Marina Hotel', 'Hafnarbraut 24'),
    ('Grand Hotel', 'Grandastigur 11')


----- Michal znowu -----------------


IF OBJECT_ID('Pasażerowie','U') IS NOT NULL
    DROP TABLE Pasażerowie
GO
CREATE TABLE Pasażerowie
(
    NazwaWycieczki NVARCHAR(50) NOT NULL,
    DataWycieczki DATE NOT NULL,
    NumerRezerwacji INT NOT NULL REFERENCES Zamówienia(IdZamówienia),
    ImieNazwisko NVARCHAR(50) NOT NULL,
    IlośćOsób INT NOT NULL,
    MiejsceOdbioru NVARCHAR(50) NULL REFERENCES Hotele(Nazwa),
    ID_klienta INT NOT NULL REFERENCES Klienci(ID_klienta)
)
GO

INSERT INTO Pasażerowie
    (NazwaWycieczki, DataWycieczki, NumerRezerwacji, ImieNazwisko, IlośćOsób, MiejsceOdbioru, ID_klienta)
VALUES
    ('Południowe Wybrzeże', '2023-02-11', 54321, 'George Smith', 2, 'Hotel Skuggi', 1),
    ('Złoty Krąg', '2023-02-11', 64321, 'John Doe', 3, 'Hilton Nordica', 2),
    ('Złoty Krąg', '2023-02-11', 74321, 'Denzel Washington', 2, 'Centerhotel Plaza', 6),
    ('Złoty Krąg', '2023-02-11', 84321, 'Ahmed Muhammad', 3, 'Marina Hotel', 7),
    ('Polowanie na zorzę polarną', '2023-02-10', 94321, 'Jane Ian', 1, 'Marina Hotel', 3),
    ('Półwysep Snaefellsens', '2023-02-10', 104321, 'Chris Mabel', 2, 'Marina Hotel', 4),
    ('Trekking po wulkanie', '2023-02-10', 114321, 'Margret Sample', 5, 'Grand Hotel', 5)
GO

------------------------------widoki Michała-------------------------

-- Widok, który pokazuje listę pasażerów na wycieczkę Złoty Krąg na konkretną datę.

GO
IF OBJECT_ID('Złoty_Krąg_2023_02_11','V') IS NOT NULL
	DROP VIEW Złoty_Krąg_2023_02_11
GO
CREATE VIEW Złoty_Krąg_2023_02_11
AS
SELECT Z.NazwaWycieczki AS [Złoty Krąg], Z.DataWycieczki AS [Data Wycieczki], P.ImieNazwisko AS [Imię i nazwisko], Z.IlośćOsób AS PAX, Z.NazwaDodatku AS [Dodatki], Z.IlośćDodatku AS [Ilość dodatków], P.MiejsceOdbioru AS [Miejsce Odbioru]
FROM Pasażerowie AS P
INNER JOIN Zamówienia AS Z ON Z.ID_zamówienia = P.NumerRezerwacji
WHERE Z.DataWycieczki = '2023-02-11' AND Z.NazwaWycieczki = 'Złoty Krąg'
GO

SELECT * FROM Złoty_Krąg_2023_02_11


-- Widok, liczący klientów ze Stanów Zjednoczonych, którzy zarezerwowali wycieczkę na Półwysep Snaefellsens.
-- Widok ów służy do celów statystycznych i zlicza rezerwacje 2-osobowe, żeby sprawdzić popularność tej wycieczki
-- w dzień walentynek.

GO
IF OBJECT_ID('Walentynki_Klienci_z_US_na_Snaefellsens','V') IS NOT NULL
	DROP VIEW Walentynki_Klienci_z_US_na_Snaefellsens
GO
CREATE VIEW [Walentynkowi klienci z US na Snaefellsnes]
AS
SELECT K.ID_klienta AS [ID], Z.IlośćOsób AS [PAX], COUNT(Z.ID_klienta) AS [Ilość par z US na Półwysep Snaefellsens]
FROM Klienci AS K
INNER JOIN Zamówienia AS Z ON K.ID_klienta = Z.ID_klienta
WHERE Adres LIKE '%US%' AND DataWycieczki = '2023-03-14' AND NazwaWycieczki = 'Półwysep Snaefellsens'
GROUP BY Z.ID_klienta, Z.IlośćOsób
HAVING IlośćOsób = 2;
GO

SELECT * FROM [Walentynkowi klienci z US na Snaefellsnes]


------------ Funkcje Michała -----------------


-- Funkcja, która wypisuje informacje o konkretnej wycieczce.

GO
IF OBJECT_ID('Pokaż_Informacje_o_Wycieczce','IF') IS NOT NULL
	DROP FUNCTION Pokaż_Informacje_o_Wycieczce
GO
CREATE FUNCTION Pokaż_Informacje_o_Wycieczce (@NazwaWycieczki NVARCHAR(50))
RETURNS TABLE
AS
RETURN 
(
	SELECT NazwaWycieczki, Dostępność, Cena$, GodzinaRozpoczęcia, IlośćMiejsc
	FROM Wycieczki
	WHERE NazwaWycieczki = @NazwaWycieczki
);
GO

SELECT * FROM Pokaż_Informacje_o_Wycieczce('Złoty Krąg');
GO

------------ Procedury Michała -------------------

--- Procedura, która po poprawnym insercie danych to tabeli Zamówienia, dodaje klienta do tabeli Klienci.

IF OBJECT_ID('Dodaj_klienta_z_Zamówień','P') IS NOT NULL
	DROP PROCEDURE Dodaj_klienta_z_Zamówień
GO
CREATE PROCEDURE Dodaj_klienta_z_Zamówień
    @ImieNazwisko NVARCHAR(50),
    @Adres NVARCHAR(50),
    @Tel NVARCHAR(50),
    @Email NVARCHAR(50),
    @NIP NVARCHAR(50)
AS
BEGIN
    DECLARE @ID_klienta INT

        IF EXISTS (SELECT 1 FROM Klienci WHERE ID_klienta = @ID_klienta)
    BEGIN
        RAISERROR ('Klient już istnieje!', 16, 1)
        RETURN
    END
    ELSE
    BEGIN
        SELECT @ID_klienta = ID_klienta FROM Zamówienia WHERE ID_zamówienia = (SELECT MAX(ID_zamówienia) FROM Zamówienia)
        INSERT INTO Klienci (ID_klienta, ImieNazwisko, Adres, Tel, Email, NIP)
        VALUES (@ID_klienta, @ImieNazwisko, @Adres, @Tel, @Email, @NIP)
    END
END;

--- Procedura, która po poprawnym insercie do tabeli Zamówienia, dodaje rekord do tabeli Pasażerowie, oparty na danych z
--- tabeli Zamówienia i Klienci

IF OBJECT_ID('Dodaj_pasażera_z_Zamówień','P') IS NOT NULL
	DROP PROCEDURE Dodaj_pasażera_z_Zamówień
GO
CREATE PROCEDURE Dodaj_pasażera_z_Zamówień
AS
BEGIN
        INSERT INTO Pasażerowie (NazwaWycieczki, DataWycieczki, NumerRezerwacji, ImieNazwisko, IlośćOsób, MiejsceOdbioru, ID_klienta)
        SELECT NazwaWycieczki, DataWycieczki, ID_zamówienia, K.ImieNazwisko, Z.IlośćOsób, MiejsceOdbioru, K.ID_klienta
        FROM Zamówienia AS Z
        JOIN Klienci AS K ON Z.ID_klienta = K.ID_klienta
END;


GO
IF OBJECT_ID('Zmień_Dostępność_Wycieczki','P') IS NOT NULL
	DROP PROCEDURE Zmień_Dostępność_Wycieczki
GO
CREATE PROCEDURE Zmień_Dostępność_Wycieczki (@NazwaWycieczki NVARCHAR(50))
AS
BEGIN
	DECLARE @Dostępność BIT;
	SET @Dostępność = (SELECT Dostępność FROM Wycieczki WHERE NazwaWycieczki = @NazwaWycieczki);

	IF @Dostępność = 1
		UPDATE Wycieczki SET Dostępność = 0 WHERE NazwaWycieczki = @NazwaWycieczki;
	ELSE
		UPDATE Wycieczki SET Dostępność = 1 WHERE NazwaWycieczki = @NazwaWycieczki;
END


---- Wyzwalacz Michała ----------

-- Wyzwalacz, który po insercie do tabeli Pasażerowie sprawdza, czy wycieczka, którą zarezerwowano
-- ma wystarczającą ilość miejsc do wykupienia. Jeżeli nie ma, to rekord jest wycofywany, jeżeli zaś
-- ma to rekord jest poprawnie wpisany do tabeli. Po tym wyzwalaczu powinno się uruchomić obie procedury
-- które wpisałem powyżej aby dopisać klienta oraz pasażera.
GO
CREATE TRIGGER Zamowienia_IlośćOsób
ON Zamówienia
AFTER INSERT
AS
BEGIN
    DECLARE @IlośćOsób INT
    DECLARE @NazwaWycieczki NVARCHAR(50) = 'Złoty Krąg'
    DECLARE @DataWycieczki DATE = (SELECT DataWycieczki FROM inserted)
    DECLARE @MaxIlośćMiejsc INT = 19

    SELECT @IlośćOsób = SUM(IlośćOsób)
    FROM Zamówienia
    WHERE NazwaWycieczki = @NazwaWycieczki AND DataWycieczki = @DataWycieczki

    IF @IlośćOsób > @MaxIlośćMiejsc
    BEGIN
        RAISERROR ('Wycieczka niedostępna', 16, 1)
        ROLLBACK
    END
    ELSE
    BEGIN
        PRINT 'Rezerwacja została dokonana'
    END
END


---------------WIDOK Mila------------------------------


-- widok, ktory pobiera dane z tabeli Zamowienia. Grupuje dane po polu IdKlienta. Dla kazdej z grup sumuje ilosc wydanych pieniedzy i tworzy nowe pole Suma Kwot. Nastepnie sortuje dane po polu Suma kwot wg malejacego porzadku. Zwraca wynik Id klienta oraz Suma Kwot


CREATE VIEW SumaKwotKlientów
AS
    SELECT ID_klienta, SUM(IlośćWycieczek * CenaWycieczki + IlośćDodatków* CenaDodatku) as 'Suma Kwot'
    FROM Zamówienia
    GROUP BY IdKlienta
    ORDER BY 'Suma Kwot' DESC;


-- Ta kwerenda tworzy widok, który połączył dane z tabel "Pracownicy" i "Zamówienia" po kluczu IdPracownika, pozwalając na zobaczenie Imienia i nazwiska pracownika oraz numeru zamówienia w jednym wyniku. Czyli widzimy, ktory pracownik byl odpowiedzialny za przyjecie zamowienia


CREATE VIEW WidokPracownicyZamowienia
AS
    SELECT P.ImieNazwisko AS [Imie i nazwisko pracownika], Z.IdZamówienia
    FROM Pracownicy AS P
        JOIN Zamówienia7 AS Z
        ON P.IdPracownika = Z.IdPracownika;


-- dwa check CONSTRAINT  
-- 1. Sprawdza czy data refundacjio jest mniejsza niz data wycieczki, czyli czy wycieczka sie juz odbyla, jesli tak - nie mozna dodac rekordu do tabeli
-- 2. Drugi widok sprawdza czy ilosc dodatkow jest mniejsza badz rowna ilosci osob, ktore wykupily wycieczke.


-----------------FUNKCJA --------------------------------
--jedna funkcja, ktora zwraca zestaw rekordow. Funckja z co najmniej jednym parametrem


--wyswietl info o pracownikach zatrudnionych pomiedzy datami. Daty podane jako  parametry


CREATE FUNCTION F_Z1(@DataPoczatkowa DATE, @DataKoncowa DATE)
RETURNS TABLE
AS
RETURN (
SELECT P.ImieNazwisko, P.Stanowisko, P.Tel, P.Email
FROM Pracownicy P
WHERE P.DataZatrudnienia BETWEEN @DataPoczatkowa AND DataKoncowa
)
SELECT *
FROM F_Z1('2009-01-01', '2013-12-31')
SELECT *
FROM F_Z1(90)


------------PROCEDURA------------
------------WYZWALACZ------------
