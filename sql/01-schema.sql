CREATE TABLE Paziente (
    paziente_id SERIAL PRIMARY KEY,
    codice_fiscale VARCHAR(16) UNIQUE NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    data_nascita DATE NOT NULL,
    sesso CHAR(1) CHECK (sesso IN ('M','F','X')),
    telefono VARCHAR(20),
    email VARCHAR(100),
    indirizzo TEXT,
    medico_base VARCHAR(100),
    note_cliniche_sint TEXT
);

CREATE TABLE Reparto (
    reparto_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ubicazione VARCHAR(100),
    telefono VARCHAR(20),
    capo_medico_id INT UNIQUE
);

CREATE TABLE Medico (
    medico_id SERIAL PRIMARY KEY,
    matricola_medico VARCHAR(20) UNIQUE NOT NULL,
    albo_numero VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    specializzazione VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    attivo BOOLEAN DEFAULT TRUE,
    reparto_id INT,
    FOREIGN KEY (reparto_id)
        REFERENCES Reparto(reparto_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- FK circolare
ALTER TABLE Reparto
ADD CONSTRAINT fk_capo_medico
FOREIGN KEY (capo_medico_id)
    REFERENCES Medico(medico_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

CREATE TABLE Ambulatorio (
    ambulatorio_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    specialita VARCHAR(100),
    reparto_id INT NOT NULL,
    FOREIGN KEY (reparto_id)
        REFERENCES Reparto(reparto_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Calendario_slot (
    slot_id SERIAL PRIMARY KEY,
    ambulatorio_id INT NOT NULL,
    medico_id INT,
    inizio TIMESTAMP NOT NULL,
    fine TIMESTAMP NOT NULL,
    stato VARCHAR(20),
    fonte VARCHAR(50),
    CHECK (fine > inizio),
    FOREIGN KEY (ambulatorio_id)
        REFERENCES Ambulatorio(ambulatorio_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (medico_id)
        REFERENCES Medico(medico_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Visita_tipo (
    codice_prestazione VARCHAR(20) PRIMARY KEY,
    descrizione TEXT NOT NULL,
    specialita VARCHAR(100),
    durata_minuti INT CHECK (durata_minuti > 0) NOT NULL
);

CREATE TABLE Utente (
    utente_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    ruolo VARCHAR(50) NOT NULL,
    medico_id INT,
    attivo BOOLEAN DEFAULT TRUE NOT NULL,
    FOREIGN KEY (medico_id)
        REFERENCES Medico(medico_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Prenotazione (
    prenotazione_id SERIAL PRIMARY KEY,
    paziente_id INT NOT NULL,
    slot_id INT NOT NULL,
    visita_tipo_id VARCHAR(20) NOT NULL,
    utente_id INT NOT NULL,
    priorita VARCHAR(20),
    motivo TEXT,
    stato VARCHAR(20) NOT NULL,
    FOREIGN KEY (paziente_id)
        REFERENCES Paziente(paziente_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (slot_id)
        REFERENCES Calendario_slot(slot_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (visita_tipo_id)
        REFERENCES Visita_tipo(codice_prestazione)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (utente_id)
        REFERENCES Utente(utente_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE 
);

CREATE TABLE Visita (
    visita_id SERIAL PRIMARY KEY,
    prenotazione_id INT UNIQUE,
    anamnesi TEXT,
    sintomi TEXT,
    esame_obiettivo TEXT,
    vitali_testo TEXT,
    stato VARCHAR(20),
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    CHECK (ended_at IS NULL OR ended_at >= started_at),
    FOREIGN KEY (prenotazione_id)
        REFERENCES Prenotazione(prenotazione_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Esame (
    esame_id SERIAL PRIMARY KEY,
    visita_id INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    codice_loinc VARCHAR(20),
    stato VARCHAR(20) NOT NULL,
    programmato_per TIMESTAMP,
    eseguito_il TIMESTAMP,
    note TEXT,
    FOREIGN KEY (visita_id)
        REFERENCES Visita(visita_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Referto (
    referto_id SERIAL PRIMARY KEY,
    esame_id INT NOT NULL,
    dati_strutturati JSONB,
    allegato_uri TEXT,
    autore_id INT,
    versione INT DEFAULT 1 NOT NULL,
    FOREIGN KEY (esame_id)
        REFERENCES Esame(esame_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (autore_id)
        REFERENCES Medico(medico_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Dizionario_diagnosi (
    codice_diagnosi VARCHAR(20) PRIMARY KEY,
    descrizione TEXT NOT NULL,
    sistema VARCHAR(50),
    attivo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Diagnosi (
    diagnosi_id SERIAL PRIMARY KEY,
    visita_id INT NOT NULL,
    codice_diagnosi VARCHAR(20) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    autore_medico_id INT,
    validata_il TIMESTAMP,
    versione INT DEFAULT 1,
    FOREIGN KEY (visita_id)
        REFERENCES Visita(visita_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (codice_diagnosi)
        REFERENCES Dizionario_diagnosi(codice_diagnosi)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (autore_medico_id)
        REFERENCES Medico(medico_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE AI_suggerimento (
    suggerimento_id SERIAL PRIMARY KEY,
    visita_id INT NOT NULL,
    modello_versione VARCHAR(50) NOT NULL,
    candidato_codice VARCHAR(20) NOT NULL,
    candidato_descr TEXT,
    confidenza DECIMAL(5,4) CHECK (confidenza BETWEEN 0 AND 1) NOT NULL,
    spiegazione TEXT,
    FOREIGN KEY (visita_id)
        REFERENCES Visita(visita_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE AI_azione_medico (
    azione_id SERIAL PRIMARY KEY,
    suggerimento_id INT NOT NULL,
    medico_id INT NOT NULL,
    azione VARCHAR(50) NOT NULL,
    nota TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (suggerimento_id)
        REFERENCES AI_suggerimento(suggerimento_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (medico_id)
        REFERENCES Medico(medico_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Consenso (
    consenso_id SERIAL PRIMARY KEY,
    paziente_id INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    valido_dal DATE NOT NULL,
    valido_al DATE,
    note TEXT,
    CHECK (valido_al IS NULL OR valido_al >= valido_dal),
    FOREIGN KEY (paziente_id)
        REFERENCES Paziente(paziente_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Log (
    log_id SERIAL PRIMARY KEY,
    entita VARCHAR(50),
    entita_id INT NOT NULL,
    azione VARCHAR(50) NOT NULL,
    utente_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    diff_testo TEXT,
    ip VARCHAR(50),
    FOREIGN KEY (utente_id)
        REFERENCES Utente(utente_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Allegato_visita (
    allegato_id SERIAL PRIMARY KEY,
    visita_id INT NOT NULL,
    tipo VARCHAR(50),
    uri TEXT NOT NULL,
    descrizione TEXT,
    FOREIGN KEY (visita_id)
        REFERENCES Visita(visita_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Trigger per settare slot occupato quando inserisco prenotazione
CREATE OR REPLACE FUNCTION aggiorna_stato_slot()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Calendario_slot
    SET stato = 'occupato'
    WHERE slot_id = NEW.slot_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prenotazione_insert
AFTER INSERT ON Prenotazione
FOR EACH ROW
EXECUTE FUNCTION aggiorna_stato_slot();