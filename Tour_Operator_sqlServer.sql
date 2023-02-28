-- CREATE DATABASE Firma_Turystyczna;
-- DROP DATABASE Firma_Turystyczna;

----- Firma Turystyczna -----
----- Autorzy Milena Kozłowska i Michał Kuranda ----
-- Próbując odwzorować realną logikę biznesową istniejących aplikacji, które korzystałaby z niniejszej
-- bazy wypróbowaliśmy wiele rozwiązań. Pisząc 'realną' mamy na myśli systemy faktycznie funkcjonujące w islandzkim
-- sektorze turystycznym.

-- Tabela Wycieczki zawiera podstawowe dane nt oferowanych produktów. Kolumna dostępność pozwala włączyć i wyłączyć
-- widoczność produktu na stronie bookingowej, a więc wartość 1 oznacza, że wycieczka jest widoczna dla przyszłego klienta.
-- Ograniczenia CHECK sprawdzają czy dodana wycieczka nie przekracza maksymalnej 'ładowności' Sprintera,
-- oraz czy godzina rozpoczęcia nie została błędnie 

IF OBJECT_ID('Wycieczki','U') IS NOT NULL
    DROP TABLE Wycieczki
GO
CREATE TABLE Wycieczki
(
    NazwaWycieczki NVARCHAR(50) PRIMARY KEY NOT NULL,
    Dostępność BIT NOT NULL,
    Cena$ MONEY NOT NULL,
    GodzinaRozpoczęcia TIME NOT NULL CHECK (GodzinaRozpoczęcia > '08:00:00'),
    IlośćMiejsc INT NOT NULL CHECK (IlośćMiejsc < 20)
)

-- Tabela Dodatki agreguje wszystkie dodatkowe usługi, które oferujemy klientom wycieczek.
-- Może to być przejażdżka konno, skutery śnieżne, wynajem butów do trekkingu lub usług profesjonalnego fotografa.

IF OBJECT_ID('Dodatki','U') IS NOT NULL
    DROP TABLE Dodatki
GO
CREATE TABLE Dodatki
(
    NazwaDodatku NVARCHAR(50) PRIMARY KEY NOT NULL,
    Cena$ MONEY NOT NULL
)

-- Tabela Hotele zawiera informacje o punktach odbioru klientów. Czemu tylko hotele? Z praktycznych doświadczeń
-- wynika, że w chaosie masowej turystyki nie może być mowy o odbiorze klientów spod indywidualnych adresów, a jedynie z
-- arbitralnie ustalonych lokalizacji.

IF OBJECT_ID('Hotele ','U') IS NOT NULL
    DROP TABLE Hotele
GO
CREATE TABLE Hotele
(
    Nazwa NVARCHAR(50) PRIMARY KEY NOT NULL,
    Adres NVARCHAR(200) NULL,
)

-- Tabela Pracownicy zawiera dane przewodników, pilotów jak i pracowników biurowych, 
-- którzy są odpowiedzialni za przyjęcie zamówienia. Zawiera ograniczenie check, 
-- które sprawdza, czy wprowadzony email jest poprawny.

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
    Adres NVARCHAR(50) NULL,
    CONSTRAINT Email CHECK(Email LIKE '%___@___%')
)

-- Tabela Klienci robi przyjmuje wsad z systemu bookingowego, deifniując nowych klientów. Mogą to być klienci detaliczni,
-- jak i klienci komercyjni, czyli inne agencje/sprzedawcy.


IF OBJECT_ID('Klienci','U') IS NOT NULL
	DROP TABLE Klienci
GO
CREATE TABLE Klienci
(
    ID_klienta INT PRIMARY KEY IDENTITY(1,1),
    ImieNazwisko NVARCHAR(50) NOT NULL,
    Adres NVARCHAR(50) NOT NULL,
    Tel NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50) NOT NULL,
    NIP NVARCHAR(50) NULL
)

-- Tabela Łącznik, podczas uruchomienia wyzwalacza po wsadzie do Klienci, przyjmuje wsad ID_klienta, żeby przekazać go
-- do tabeli Zamówienia.

IF OBJECT_ID('Łącznik','U') IS NOT NULL
    DROP TABLE Łącznik
GO
CREATE TABLE Łącznik
(
    ID_klienta INT PRIMARY KEY
)

-- Tabela Zamówienia przyjmuje wsad z systemu bookingowego, który nawiązuje relację z konkretnym klientem
-- z tabeli Klienci, przy pomocy najnowszego rekordu z tabeli Łącznik. Wsad z systemu bookingowego
-- obejmuje wszystkie dane potrzebne do wystawienia rachunku. Zamówienia przyjmują wsady zarówno dla
-- zarezerwowanych wycieczek i ilości osób w rezerwacji (IlośćWycieczek) jak i dla dodatków.
-- W przypadku rezerwacji powiązanego dodatku, pojawia się on jako osobny rekord z tożsamą do swojej wycieczki nazwą i datą,
-- NULLEM w IlośćWycieczek, za to ma wpisaną NazwaDodatku, ilość i cenę.

IF OBJECT_ID('Zamówienia ','U') IS NOT NULL
    DROP TABLE Zamówienia
GO
CREATE TABLE Zamówienia
(
    ID_zamówienia INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    NumerRezerwacji INT NOT NULL,
    DataZamówienia DATE DEFAULT NULL,
    NazwaWycieczki NVARCHAR(50) NULL FOREIGN KEY REFERENCES Wycieczki(NazwaWycieczki),
    IlośćWycieczek INT NOT NULL,
    DataWycieczki DATE NOT NULL,
    NazwaDodatku NVARCHAR(50) NULL FOREIGN KEY REFERENCES Dodatki(NazwaDodatku),
    IlośćDodatków INT NOT NULL,
    CenaWycieczki INT NOT NULL,
    CenaDodatku INT NOT NULL,
    MiejsceOdbioru NVARCHAR(50) NULL REFERENCES Hotele(Nazwa),
    ID_klienta INT FOREIGN KEY REFERENCES Klienci(ID_klienta),
    ID_pracownika INT FOREIGN KEY REFERENCES Pracownicy(ID_pracownika)
)

-- Tabela Refundacje przetrzymuje dane o wszytskich refundacjach, które miały miejsce. 
-- Zawiera ograniczenie check constraint, które sprawdza czy data wycieczki jest póżniejsza niż data refundacji. 
-- Jeśli wycieczka już się odbyła i pasażer wziąć w niej udział, nie ma możliwości dodania rekordu do tabeli refundacje.

IF OBJECT_ID('Refundacje','U') IS NOT NULL
    DROP TABLE Refundacje
GO
CREATE TABLE Refundacje
(
    ID_refundacji INT PRIMARY KEY IDENTITY(1,1),
    ID_zamówienia INT REFERENCES Zamówienia (ID_zamówienia),
    DataRefundacji DATE NOT NULL,
    DataWycieczki DATE NOT NULL,
    KwotaRefundacji MONEY NOT NULL,
    CONSTRAINT DataRefundacji
    CHECK (DataRefundacji < DataWycieczki)
)

-- Tabela Pasażerowie pobiera dane z zamówienia na cele stworzenia konkretnych list pasażerów
-- kompilowanych dla codziennych operacji.

IF OBJECT_ID('Pasażerowie','U') IS NOT NULL
    DROP TABLE Pasażerowie
GO
CREATE TABLE Pasażerowie
(
    NazwaWycieczki NVARCHAR(50) NOT NULL,
    DataWycieczki DATE NOT NULL,
    NumerRezerwacji INT NOT NULL REFERENCES Zamówienia(ID_zamówienia),
    ImieNazwisko NVARCHAR(50) NOT NULL,
    IlośćOsób INT NOT NULL,
    MiejsceOdbioru NVARCHAR(50) NOT NULL,
    ID_klienta INT NOT NULL
)
GO
test


---------------------------
--------- Widoki ----------
---------------------------


-- Widok Złoty_Krąg_2023_02_11 jest przykładowym widokiem tworzonym przez backend systemu na wycieczkę
-- w konkretnym terminie. Wynik kwerendy z tego widoku będzie można wydrukować i wręczyć kierowcy,
-- który sprawnie pobierze dodatki z magazynu i odbierze właściwych klientów z właściwej lokalizacji.

GO
IF OBJECT_ID('Złoty_Krąg_2023_02_11','V') IS NOT NULL
	DROP VIEW Złoty_Krąg_2023_02_11
GO
CREATE VIEW Złoty_Krąg_2023_02_11
AS
    SELECT Z.NazwaWycieczki AS [Złoty Krąg], Z.DataWycieczki AS [Data Wycieczki], P.ImieNazwisko AS [Imię i nazwisko], Z.IlośćWycieczek AS PAX, Z.NazwaDodatku AS [Dodatki], Z.IlośćDodatków AS [Ilość dodatków], P.MiejsceOdbioru AS [Miejsce Odbioru]
    FROM Pasażerowie AS P
        INNER JOIN Zamówienia AS Z ON Z.ID_zamówienia = P.NumerRezerwacji
    WHERE Z.DataWycieczki = '2023-02-11' AND Z.NazwaWycieczki = 'Złoty Krąg'
GO

SELECT *
FROM Złoty_Krąg_2023_02_11

-- Widok, liczący klientów ze Stanów Zjednoczonych, którzy zarezerwowali wycieczkę na Półwysep Snaefellsens.
-- Widok ów służy do celów statystycznych i zlicza rezerwacje 2-osobowe, żeby sprawdzić popularność tej wycieczki
-- w dzień walentynek. Oczywiście nie ma pewności, że każda rezerwacja 2-osobowa została zrobiona przez parę,
-- wedle dostępnych już statystyk większość rezerwacji 2-osobowych stanowią pary, a więc wynik kwerendy będzie 
-- rozsądnym przybliżeniem.

GO
IF OBJECT_ID('Walentynkowi klienci z US na Snaefellsnes','V') IS NOT NULL
	DROP VIEW [Walentynkowi klienci z US na Snaefellsnes]
GO
CREATE VIEW [Walentynkowi klienci z US na Snaefellsnes]
AS
    SELECT Z.ID_klienta AS [ID], Z.IlośćWycieczek AS [PAX], COUNT(Z.ID_klienta) AS [Ilość par z US na Półwysep Snaefellsens]
    FROM Klienci AS K
        INNER JOIN Zamówienia AS Z ON K.ID_klienta = Z.ID_klienta
    WHERE K.Adres LIKE '%US%' AND Z.DataWycieczki = '2023-03-14' AND Z.NazwaWycieczki = 'Półwysep Snaefellsens'
    GROUP BY Z.ID_klienta, Z.IlośćWycieczek
    HAVING Z.IlośćWycieczek = 2;
GO
SELECT *
FROM [Walentynkowi klienci z US na Snaefellsnes]

-- Widok, który pobiera dane z tabeli Zamówienia. Grupuje dane po polu ID_klienta.
-- Dla każdej z grup sumuje ilość wydanych pieniędzy i tworzy nowe pole Suma Kwot. Zwraca wynik Id klienta oraz Suma Kwot.
GO
IF OBJECT_ID('SumaKwotKlientów','V') IS NOT NULL
	DROP VIEW SumaKwotKlientów
GO
CREATE VIEW SumaKwotKlientów
AS
    SELECT ID_klienta, SUM(IlośćWycieczek * CenaWycieczki + IlośćDodatków * CenaDodatku) as 'Suma Kwot'
    FROM Zamówienia
    GROUP BY ID_klienta

-- Ta kwerenda tworzy widok, który połączył dane z tabel "Pracownicy" i "Zamówienia" po kluczu ID_pracownika, 
-- pozwalając na zobaczenie imienia i nazwiska pracownika oraz numeru zamówienia w jednym wyniku. 
-- Czyli widzimy, który pracownik był odpowiedzialny za przyjęcie zamówienia.

GO
IF OBJECT_ID('WidokPracownicyZamowienia','V') IS NOT NULL
	DROP VIEW WidokPracownicyZamowienia
GO
CREATE VIEW WidokPracownicyZamowienia
AS
    SELECT P.ImieNazwisko AS [Imie i nazwisko pracownika], Z.ID_zamówienia
    FROM Pracownicy AS P
        JOIN Zamówienia AS Z
        ON P.ID_pracownika = Z.ID_pracownika;


------------------------------
---------- Funkcje -----------
------------------------------


-- Funkcja Pokaż_Informacje_o_Wycieczce wypisuje informacje o konkretnej wycieczce. Teoretycznie
-- odpowiednia funkcja istniałaby dla każdej wycieczki w ofercie.

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
SELECT *
FROM Pokaż_Informacje_o_Wycieczce('Złoty Krąg');
GO

-- Ta funkcja wyświetli dane pracowników (imię i nazwisko, stanowisko, nr telefonu oraz email), 
-- którzy są zatrudnieni pomiędzy datami podanymi jako parametr. 

IF OBJECT_ID('F_Z1','IF') IS NOT NULL
	DROP FUNCTION F_Z1
GO
CREATE FUNCTION F_Z1(@DataPoczatkowa DATE, @DataKoncowa DATE)
RETURNS TABLE
AS
RETURN (
SELECT P.ImieNazwisko, P.Stanowisko, P.Tel, P.Email
FROM Pracownicy AS P
WHERE P.DataZatrudnienia BETWEEN @DataPoczatkowa AND @DataKoncowa
)
GO
-- wywołanie funkcji

SELECT *
FROM F_Z1('2009-01-01', '2013-12-31')
GO
--------------------------------
---------- Procedury -----------
--------------------------------


--- Procedura Dodaj_pasażera_z_Zamówień, która po poprawnym insercie do tabeli Zamówienia, dodaje rekord do tabeli Pasażerowie, oparty na danych z
--- tabeli Zamówienia i Klienci

IF OBJECT_ID('Dodaj_pasażera_z_Zamówień','P') IS NOT NULL
	DROP PROCEDURE Dodaj_pasażera_z_Zamówień
GO
CREATE PROCEDURE Dodaj_pasażera_z_Zamówień
AS
BEGIN
    INSERT INTO Pasażerowie
        (NazwaWycieczki, DataWycieczki, NumerRezerwacji, ImieNazwisko, IlośćOsób, MiejsceOdbioru, ID_klienta)
    SELECT NazwaWycieczki, DataWycieczki, ID_zamówienia, K.ImieNazwisko, Z.IlośćWycieczek, Z.MiejsceOdbioru, Z.ID_klienta
    FROM Zamówienia AS Z
        JOIN Klienci AS K ON Z.ID_klienta = K.ID_klienta
END;

-- Procedura SprawdzKwoteRefundacji polega na porównaniu kwoty zwrotu z całkowitym kosztem zamówienia. 
-- Przyjmuje 5 parametrów. Najpierw deklaruje zmienną @KwotaZamówienia, 
-- następnie oblicza całkowity koszt zamówienia sumując koszty wycieczek i usług dodatkowych. 
-- W kolejnym kroku sprawdza, czy kwota zwrotu jest większa niż całkowity koszt zamówienia. 
-- Jeśli tak, zgłasza błąd i zwraca 1, w przeciwnym razie wstawia rekord zwrotu do tabeli Refundacje.

IF OBJECT_ID('usp_sprawdzKwoteRefundacji','P') IS NOT NULL
	DROP PROC usp_sprawdzKwoteRefundacji
GO
CREATE PROCEDURE usp_sprawdzKwoteRefundacji
    @ID_refundacji INT,
    @ID_zamówienia INT,
    @DataRefundacji DATE,
    @DataWycieczki DATE,
    @KwotaRefundacji INT
AS
BEGIN
    DECLARE @KwotaZamówienia INT
    SELECT @KwotaZamówienia = SUM(CenaWycieczki*IlośćWycieczek + CenaDodatku*IlośćDodatków)
    FROM Zamówienia
    WHERE ID_zamówienia = @ID_zamówienia
    IF @KwotaZamówienia < @KwotaRefundacji
    BEGIN
        RAISERROR('Kwota refundacji jest większa niż kwota zamówienia. Rekord nie zostanie dodany, %d', 16, 1, @KwotaRefundacji)
        RETURN(1)
    END
    ELSE
    BEGIN
        INSERT INTO Refundacje
            (ID_refundacji, ID_zamówienia, DataRefundacji, DataWycieczki, KwotaRefundacji)
        VALUES
            (@ID_refundacji, @ID_zamówienia, @DataRefundacji, @DataWycieczki, @KwotaRefundacji)
    END
END
GO
-- wywolanie procedury
EXEC usp_sprawdzKwoteRefundacji 110355, 94321, '2023-10-20', '2023-02-10', 400
GO


---------------------------------
---------- Wyzwalacze -----------
---------------------------------

-- Wyzwalacz zapobiegajDodawaniuHotelu uniemożliwi dopisywanie rekordów do tabeli Hotele.

IF OBJECT_ID('zapobiegajDodawaniuHotelu', 'TR') IS NOT NULL
    DROP TRIGGER zapobiegajDodawaniuHotelu
GO
CREATE TRIGGER zapobiegajDodawaniuHotelu ON Hotele
AFTER INSERT
AS
RAISERROR('Nie można dopisywać rekordów do tabeli Hotele', 16, 1);
ROLLBACK TRANSACTION;
GO
-- użycie wyzwalacza
INSERT INTO Hotele
    (Nazwa)
VALUES('Nowy Hotel')

-- Wyzwalacz Zamowienia_IlośćOsób sprawdza przy insercie do tabeli Zamówienia, czy osiągnięto
-- maksymalną pojemność autobusu, sumując liczbę wszystkich pasażerów, którzy dotychczas 
-- zarezerwowali konkretną wycieczkę na konkretną datę. Każda wycieczka z listy oferowanych
-- wycieczek powinna mieć taki wyzwalacz.

IF OBJECT_ID('Zamowienia_IlośćOsóbPW', 'TR') IS NOT NULL
    DROP TRIGGER Zamowienia_IlośćOsóbPW
GO
CREATE TRIGGER Zamowienia_IlośćOsóbPW
ON Zamówienia
AFTER INSERT
AS
BEGIN
    DECLARE @IlośćOsób INT
    DECLARE @NazwaWycieczki NVARCHAR(50) = 'Południowe Wybrzeże'
    DECLARE @DataWycieczki DATE = (SELECT DataWycieczki
    FROM inserted)
    DECLARE @MaxIlośćMiejsc INT = 19

    SELECT @IlośćOsób = SUM(IlośćWycieczek)
    FROM Zamówienia
    WHERE NazwaWycieczki = @NazwaWycieczki AND DataWycieczki = @DataWycieczki

    IF @IlośćOsób > @MaxIlośćMiejsc
    BEGIN
        RAISERROR ('Wycieczka niedostępna', 16, 1)
        DELETE FROM Zamówienia
        WHERE  ID_zamówienia = (SELECT Max(ID_zamówienia)
        FROM Zamówienia)
    END
    ELSE
    BEGIN
        PRINT 'Rezerwacja została dokonana'
    END
END
GO

IF OBJECT_ID('Zamowienia_IlośćOsóbZK', 'TR') IS NOT NULL
    DROP TRIGGER Zamowienia_IlośćOsóbZK
GO
CREATE TRIGGER Zamowienia_IlośćOsóbZK
ON Zamówienia
AFTER INSERT
AS
BEGIN
    DECLARE @IlośćOsób INT
    DECLARE @NazwaWycieczki NVARCHAR(50) = 'Złoty Krąg'
    DECLARE @DataWycieczki DATE = (SELECT DataWycieczki
    FROM inserted)
    DECLARE @MaxIlośćMiejsc INT = 19

    SELECT @IlośćOsób = SUM(IlośćWycieczek)
    FROM Zamówienia
    WHERE NazwaWycieczki = @NazwaWycieczki AND DataWycieczki = @DataWycieczki

    IF @IlośćOsób > @MaxIlośćMiejsc
    BEGIN
        RAISERROR ('Wycieczka niedostępna', 16, 1)

    END
    ELSE
    BEGIN
        PRINT 'Rezerwacja została dokonana'
    END
END
GO

-- Wyzwalacz tr_Dodaj_Klienta po wsadzie do Klientów sprawdza czy dany Klient dokonujący zamówienia już figuruje w tabeli Klienci czy nie.
-- Jeżeli figuruje to następuje wsad identyfikatora klienta do tabeli Łącznik. Jeżeli klient nie figuruje, to następuje poprawne
-- utworzenie rekordu z jego danymi w tabeli Klienci, a następnie wygenerowany dla niego identyfikator zostaje wsadzony do łącznika.
-- W Łączniku identyfikator klienta w bieżącej sesji będzie pierwszym wpisem, więc jest łatwy do odnalezienia podczas wsadu do tabeli
-- Zamówienia, która owego identyfikatora wymaga.

IF OBJECT_ID('tr_Dodaj_Klienta', 'TR') IS NOT NULL
    DROP TRIGGER tr_Dodaj_Klienta
GO
CREATE TRIGGER tr_Dodaj_Klienta
ON Klienci
AFTER INSERT
AS
BEGIN
    DECLARE @KlientIstnieje INT
    SET @KlientIstnieje = 0
    DECLARE @ImieNazwisko NVARCHAR(50), @Adres NVARCHAR(50), @Tel NVARCHAR(50), @Email NVARCHAR(50), @NIP NVARCHAR(50)
    SELECT @ImieNazwisko = i.ImieNazwisko, @Adres = i.Adres, @Tel = i.Tel, @Email = i.Email, @NIP = i.NIP
    FROM inserted AS i;

    IF (SELECT COUNT(K.ID_klienta)
    FROM inserted AS i, Klienci AS K
    WHERE i.ImieNazwisko = K.ImieNazwisko AND i.Adres = K.Adres AND i.Tel = K.Tel AND i.Email = K.Email AND i.NIP = K.NIP) > 1
    BEGIN
        SET @KlientIstnieje = 1
        RAISERROR('Klient o podanych danych już istnieje.', 16, 1)
    END
    IF @KlientIstnieje = 1
    BEGIN
        DELETE FROM Klienci
        WHERE  ID_klienta = (SELECT Max(ID_klienta)
        FROM Klienci)
    END
    INSERT INTO Łącznik
    SELECT ID_klienta
    FROM Klienci AS K
    WHERE K.ImieNazwisko = @ImieNazwisko AND K.Adres = @Adres AND K.Tel = @Tel AND K.Email = @Email
END

INSERT INTO Klienci
    (ImieNazwisko, Adres, Tel, Email, NIP)
VALUES
    ('John Goodman', 'Salt Lake City, US', '001345678901', 'goodman.j87@gmail.com', '798320189')
INSERT INTO Klienci
    (ImieNazwisko, Adres, Tel, Email, NIP)
VALUES
    ('Mary Jane Watson', 'NY, US', '001322667788', 'mj.watson@gmail.com', '7456777754')
INSERT INTO Klienci
    (ImieNazwisko, Adres, Tel, Email, NIP)
VALUES
    ('Peter Parker', 'Huston, US', '001999654433', 'pp1991@gmail.com', '45665656')
INSERT INTO Klienci
    (ImieNazwisko, Adres, Tel, Email, NIP)
VALUES
    ('Sansa Stark', 'Boston, US', '001223344556', 'gots07e01@gmail.com', '3345765467')


INSERT INTO Klienci
    (ImieNazwisko, Adres, Tel, Email, NIP)
VALUES
    ('Peter Parker', 'Huston, US', '001999654433', 'pp1991@gmail.com', '45665656')
INSERT INTO Klienci
    (ImieNazwisko, Adres, Tel, Email, NIP)
VALUES
    ('The Rock', 'Los Angeles, US', '001876437892', 'rock@gmail.com', '478034588')


---------- Wsady i Selecty

SELECT *
FROM Klienci
SELECT *
FROM Łącznik
SELECT *
FROM Zamówienia
DELETE FROM Zamówienia

INSERT INTO Zamówienia
    (NumerRezerwacji, DataZamówienia, NazwaWycieczki, IlośćWycieczek, DataWycieczki, NazwaDodatku, IlośćDodatków, CenaWycieczki, CenaDodatku, MiejsceOdbioru, ID_klienta, ID_pracownika)
VALUES
    (84321, GETDATE(), 'Południowe Wybrzeże', 2, '2023-02-11', NULL, 0, 110, 0, 'Hotel Skuggi', 5, 12345)

INSERT INTO Zamówienia
    (NumerRezerwacji, DataZamówienia, NazwaWycieczki, IlośćWycieczek, DataWycieczki, NazwaDodatku, IlośćDodatków, CenaWycieczki, CenaDodatku, MiejsceOdbioru, ID_klienta, ID_pracownika)
VALUES
    (54321, GETDATE(), 'Południowe Wybrzeże', 5, '2023-02-11', NULL, 0, 110, 0, 'Hotel Skuggi', 3, 12345)
INSERT INTO Zamówienia
    (NumerRezerwacji, DataZamówienia, NazwaWycieczki, IlośćWycieczek, DataWycieczki, NazwaDodatku, IlośćDodatków, CenaWycieczki, CenaDodatku, MiejsceOdbioru, ID_klienta, ID_pracownika)
VALUES
    (74321, GETDATE(), 'Południowe Wybrzeże', 5, '2023-02-11', NULL, 0, 110, 0, 'Hotel Skuggi', 3, 12345)
INSERT INTO Zamówienia
    (NumerRezerwacji, DataZamówienia, NazwaWycieczki, IlośćWycieczek, DataWycieczki, NazwaDodatku, IlośćDodatków, CenaWycieczki, CenaDodatku, MiejsceOdbioru, ID_klienta, ID_pracownika)
VALUES
    (54321, GETDATE(), null, 0, '2023-01-13', 'Fotelik dziecięcy', 1, 0, 10, null, 1, 12345)

INSERT INTO Wycieczki
    (NazwaWycieczki, Dostępność, Cena$, GodzinaRozpoczęcia, IlośćMiejsc)
VALUES
    ('Południowe Wybrzeże', 1, 120, '08:30:00', 19)

INSERT INTO Hotele
    (Nazwa, Adres)
VALUES
    ('Hotel Skuggi', 'Hverfisgata 95'),
    ('Hilton Nordica', 'Sudurlandsbraut 1'),
    ('Centerhotel Plaza', 'Sudurlandsbraut 1'),
    ('Marina Hotel', 'Hafnarbraut 24'),
    ('Grand Hotel', 'Grandastigur 11')

INSERT INTO Pracownicy
    (ID_Pracownika, ImieNazwisko, Stanowisko, DataZatrudnienia, Tel, Email, Adres)
VALUES
    (12345, 'Unshimi Krodande', 'Operacje', '2013-05-06', 19556604, 'unshimi@gmail.com', 'Storens vei 13, Kongsberg'),
    (22345, 'Elidvu Bhiulnu', 'Przewodnik', '2010-10-01', 666606, 'elidvu@gmail.com', 'Eidstoppen 16, Hof'),
    (32345, 'Nadendi Niesa', 'Przewodnik', '2011-02-01', 766707, 'nadendi@gmail.com', 'Roaveienn 20, Hokksund'),
    (42345, 'Ghairrakh Bhegeruh', 'Pilot', '2012-03-01', 866707, 'ghairrakh@gmail.com', 'Solhoyveine 20, Holmestrand'),
    (52345, 'Bhepiksho Zibir', 'Sekretarz', '2009-08-06', 962747, 'bhepiksho@gmail.com', 'Markveien 2, Kongsberg'),
    (62345, 'Rhihoco Ralnud', 'Pilot', '2001-02-06', 161717, 'rhihoco@gmail.com', 'Funkelia 18, Kongsberg' )

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
