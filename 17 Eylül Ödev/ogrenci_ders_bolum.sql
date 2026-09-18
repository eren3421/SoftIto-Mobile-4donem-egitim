-- 1. Bölüm Tablosu
CREATE TABLE Bolum (
    bolum_id INT PRIMARY KEY,
    bolum_adi VARCHAR(100) NOT NULL,
    bolum_baskani VARCHAR(100)
);

-- 2. Öğrenci Tablosu
CREATE TABLE Ogrenci (
    ogrenci_no INT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    eposta VARCHAR(100) UNIQUE NOT NULL,
    bolum_id INT NOT NULL,
    CONSTRAINT fk_ogrenci_bolum 
        FOREIGN KEY (bolum_id) REFERENCES Bolum(bolum_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3. Ders Tablosu
CREATE TABLE Ders (
    ders_kodu VARCHAR(20) PRIMARY KEY,
    ders_adi VARCHAR(100) NOT NULL,
    kredi INT NOT NULL CHECK (kredi > 0),
    bolum_id INT NOT NULL,
    CONSTRAINT fk_ders_bolum 
        FOREIGN KEY (bolum_id) REFERENCES Bolum(bolum_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 4. Öğrenci - Ders İlişki (Kayıt / Not) Tablosu
CREATE TABLE Ogrenci_Ders (
    ogrenci_no INT NOT NULL,
    ders_kodu VARCHAR(20) NOT NULL,
    harf_notu VARCHAR(2),
    PRIMARY KEY (ogrenci_no, ders_kodu),
    CONSTRAINT fk_kayit_ogrenci 
        FOREIGN KEY (ogrenci_no) REFERENCES Ogrenci(ogrenci_no) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_kayit_ders 
        FOREIGN KEY (ders_kodu) REFERENCES Ders(ders_kodu) 
        ON DELETE CASCADE ON UPDATE CASCADE
);